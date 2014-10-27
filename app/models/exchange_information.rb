class ExchangeInformation

  class MissingKeyError < StandardError
    def initialize(key)
      super("Missing required key: #{key}") 
    end
  end

  include Singleton

  REQUIRED_KEYS = [
    'receiver_id',
    'osb_host', 'osb_username', 'osb_password', 'osb_nonce', 'osb_created',
    'invalid_argument_queue', 'processing_failure_queue'
  ]

  # TODO: I have a feeling we may be using this pattern
  #       A LOT.  Look into extracting it if we repeat.
  def initialize
    @config = YAML.load_file(File.join(HbxEnterprise::App.root,'..','config', 'exchange.yml'))
    ensure_configuration_values(@config)
  end

  def ensure_configuration_values(conf)
    REQUIRED_KEYS.each do |k|
      if @config[k].blank?
        raise MissingKeyError.new(k)
      end
    end
  end

  def receiver_id
    @config['receiver_id']
  end

  def osb_host
    @config['osb_host']
  end

  def osb_username
    @config['osb_username']
  end

  def osb_password
    @config['osb_password']
  end

  def osb_nonce
    @config['osb_nonce']
  end

  def osb_created
    @config['osb_created']
  end

  def invalid_argument_queue 
    @config['invalid_argument_queue']
  end

  def processing_failure_queue
    @config['processing_failure_queue']
  end

  def self.receiver_id
    self.instance.receiver_id
  end

  def self.osb_host
    self.instance.osb_host
  end

  def self.osb_username
    self.instance.osb_username
  end

  def self.osb_password
    self.instance.osb_password
  end

  def self.osb_nonce
    self.instance.osb_nonce
  end

  def self.osb_created
    self.instance.osb_created
  end

  def self.invalid_argument_queue
    self.instance.invalid_argument_queue
  end

  def self.processing_failure_queue
    self.instance.processing_failure_queue
  end
end
