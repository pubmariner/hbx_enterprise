# Connection.new takes host and port.

# If you want to use a YML file for config, use this instead:
#
unless Mongoid.configured?
  Mongoid.load!(File.join(Padrino.root, 'config', 'mongoid.yml'), Padrino.env.to_s)
end

OpenhbxWorkflow::Coordination.implementer = BatchCoordinationStep
