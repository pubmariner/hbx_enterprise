require 'spec_helper'

describe Listeners::EmployerDigestListener do
  let(:payload) { "" }
  let(:delivery_info) { double(:routing_key => routing_key, :delivery_tag => "a delivery tag") }
  let(:properties) { double(:headers => headers) }
  let(:channel) { double }
  let(:queue) { double }
  let(:csv) { [] }
  let(:headers) { {} }
  let(:routing_key) { "" }

  subject { Listeners::EmployerDigestListener.new(channel, queue, csv) }

end
