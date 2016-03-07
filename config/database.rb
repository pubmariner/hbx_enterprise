# Connection.new takes host and port.

# If you want to use a YML file for config, use this instead:
#
unless Mongoid.configured?
  Mongoid.load!(File.join(Padrino.root, 'config', 'mongoid.yml'), Padrino.env.to_s)
end
#
# And add a config/database.yml file like this:
#   development:
#     sessions:
#       default:
#         database: hbx_enterprise_development
#         hosts:
#           - localhost:27017
#   production:
#     sessions:
#       default:
#         database: hbx_enterprise_production
#         hosts:
#           - localhost:27017
#   test:
#     sessions:
#       default:
#         database: hbx_enterprise_test
#         hosts:
#           - localhost:27017
#
#
# More installation and setup notes are on http://mongoid.org/en/mongoid/docs/installation.html#configuration
