$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))

module Zerigo
  class Config < Configurable # :nodoc:
    if defined?(Rails)
      config.config_path = Rails.root.join "config"
    else
      config.config_path = File.expand_path('../config.yml', __FILE__)
    end
  end
end

require 'zerigo/railtie' if defined?(Rails)

# Load components

require 'zerigo/api'
require 'zerigo/object_base'
require 'zerigo/object_collection'
require 'zerigo/zone'
require 'zerigo/zone_template'
require 'zerigo/host'
require 'zerigo/host_template'

