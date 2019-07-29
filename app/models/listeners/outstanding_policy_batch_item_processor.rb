module Listeners
  class OutstandingPolicyBatchItemProcessor < Amqp::Client
    BatchItemInfo = Struct.new(:batch_name, :index, :batch_size, :policy_id)
    ItemProcessingFailure = Struct.new(:retry, :return_status, :error_body, :batch_body)

    def on_message(delivery_info, properties, payload)
      headers = (properties.headers || {})
      should_publish = (headers["publish"].to_s.downcase == "true")
      b_info = BatchItemInfo.new(
        headers["batch_name"],
        headers["index"],
        headers["batch_size"],
        headers["policy_id"]
      )
      sc = create_failure_handler(delivery_info, b_info)
      sc.and_then do |args|
        policy_body = request_policy_body(b_info.policy_id, should_publish)
        create_policy_in_glue(b_info.policy_id, policy_body)
        store_batch_item(b_info, JSON.dump({
          policy_id: b_info.policy_id,
          processed: true,
          body: policy_body
        }))
        report_result("completed", "200", b_info, policy_body) 
        channel.ack(delivery_info.delivery_tag,false)
      end
    end

    def create_policy_in_glue(policy_id, policy_body)
      cv = policy_body.gsub("active_year", "plan_year")
      qr_uri = "urn:dc0:terms:v1:qualifying_life_event#initial_enrollment"
      request_props = {
        :routing_key => "enrollment.create",
        :headers => {
          :qualifying_reason_uri => qr_uri
        }
      }
      begin
        di, prop, payload = Amqp::Requestor.new(connection).request(request_props, policy_body, 180)
        return_code = prop.headers["return_status"]
        if "200" != return_code.to_s
          error_body = JSON.load(payload)
          err_string = String.new
          err_string << flatten_to_list("", error_body).join("\n")
          throw :processing_failure, ItemProcessingFailure.new(false, return_code, "Publishing failure.", batch_body_for(policy_id, false, err_string, policy_body))
        end
      rescue Timeout::Error => e
        throw :processing_failure, ItemProcessingFailure.new(false, "503", "Timeout publishing policy.", batch_body_for(policy_id, false, "timeout during publishing to glue", policy_body))
      end
    end

    def request_policy_body(policy_id, should_publish)
      requestor = Amqp::Requestor.new(connection)
      request_properties = {
        :routing_key => "resource.policy",
        :headers => {
          :policy_id => policy_id
        }
      }
      begin
        di, r_props, r_body = requestor.request(request_properties, "")
        extract_policy_payload(policy_id, r_props, r_body, should_publish)
      rescue Timeout::Error => e
        throw :processing_failure, ItemProcessingFailure.new(true, "503", "Timeout retrieving policy.", nil)
      end
    end

    def extract_policy_payload(policy_id, r_props, r_body, should_publish)
      headers = r_props.headers || {}
      return_status = headers["return_status"]
      case return_status.to_s
      when "200"
        elig_reason = headers["eligibility_event_kind"]
        check_should_publish(policy_id, r_body, should_publish)
        check_elig_reason(policy_id, elig_reason, r_body)
      when "503"
        throw :processing_failure, ItemProcessingFailure.new(true, "503", "Timeout retrieving policy.", nil)
      when "404"
        throw :processing_failure, ItemProcessingFailure.new(false, "404", "No such policy.", batch_body_for(policy_id, false, "not found",nil)) 
      else
        throw :processing_failure, ItemProcessingFailure.new(false, "500", "Server error", batch_body_for(policy_id, false, "Server error", ""))
      end
    end

    def check_should_publish(policy_id, r_body, should_publish)
      unless should_publish
        throw :processing_failure, ItemProcessingFailure.new(false, "302", "Batch marked do not publish.", batch_body_for(policy_id, false, "This batch is not marked for publishing.", r_body))
      end
    end

    def check_elig_reason(policy_id, elig_reason, r_body)
      unless elig_reason == "new_hire"
        throw :processing_failure, ItemProcessingFailure.new(false, "302", "Eligibility reason currently excluded.", batch_body_for(policy_id, false, "Eligibility reason #{elig_reason} is currently excluded from processing", r_body))
      end
      r_body
    end

    def batch_body_for(policy_id, processed, error_message, policy)
      JSON.dump({
        policy_id: policy_id,
        error_message: error_message,
        processed: processed,
        body: policy
      })
    end

    def store_batch_item(b_info, b_body)
      OpenhbxWorkflow::Coordination.store_batch_entry(
        ::OpenhbxWorkflow::CoordinationKind::FULL_COLLECTION,
        b_info.batch_name,
        b_info.index,
        b_info.batch_size,
        nil,
        ::OpenhbxWorkflow::LargeData.new(b_body)
      )
    end

    def report_result(result_tag, return_status, b_item_info, result_body)
      with_confirmed_channel do |chan|
        out_ex = chan.fanout(ExchangeInformation.event_publish_exchange, :durable => true)
        out_ex.publish(result_body, {
          :routing_key => "info.events.policy.outstanding_policy_batch_item.#{result_tag}",
          :timestamp => Time.now.to_i,
            :app_id => "hbx_enterprise",
            :headers => {
              :batch_name => b_item_info.batch_name,
              :index => b_item_info.index,
              :batch_size => b_item_info.batch_size,
              :policy_id => b_item_info.policy_id,
              :return_status => return_status
            }
        })
      end
    end

    def create_failure_handler(delivery_info, b_info)
      ShortCircuit.on(:processing_failure) do |issue|
        if issue.retry
          report_result("failed_retrying", issue.return_status, b_info, issue.error_body)
          channel.reject(delivery_info.delivery_tag, true)
        else
          store_batch_item(b_info, issue.batch_body)
          report_result("completed", issue.return_status, b_info, issue.error_body)
          channel.ack(delivery_info.delivery_tag, false)
        end
      end
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.outstanding_policy_batch_item_processor"
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 15)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
      conn.close
    end
  end
end
