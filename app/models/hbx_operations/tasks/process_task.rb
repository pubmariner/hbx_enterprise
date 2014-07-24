class HbxOperations::Tasks::ProcessTask
  include Mongoid::Document

  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String
  field :kind, type: String
  field :sla, as: :service_level_agreement_in_days, type: Integer

  embedded_in :business_process, :class_name => 'HbxOperations::BusinessProcess'

  validates_presence_of :name, :kind
  # do a reflection of .rb files in this folder to determine supported "kinds"
  # validates_inclusion_of :kind, in: []

end
