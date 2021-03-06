require 'neography'
require 'neoid/version'
require 'neoid/instance'
require 'neoid/config'
require 'neoid/model_config'
require 'neoid/model_additions'
require 'neoid/search_session'
require 'neoid/node'
require 'neoid/relationship'
require 'neoid/batch'
require 'neoid/database_cleaner'
require 'neoid/railtie' if defined?(Rails)

module Neoid
  DEFAULT_FULLTEXT_SEARCH_INDEX_NAME = :neoid_default_search_index
  NODE_AUTO_INDEX_NAME = 'node_auto_index'
  RELATIONSHIP_AUTO_INDEX_NAME = 'relationship_auto_index'
  UNIQUE_ID_KEY = 'neoid_unique_id'

  class << self

    attr_accessor :default_connection_name

    def connections
      @connections ||= {}
    end

    def connection(name = nil)
      if !name || name == :default
        name = default_connection_name
        if !name && connections.size == 1
          return connections.values.first
        end
      end

      raise ArgumentError.new("No Neo4j connection with name #{name}.") unless name && connections.key?(name)

      if connections.key? name
        connections[name]
      end
    end

    def add_connection(name, connection, &block)
      instance = Neoid::Instance.new(connection)
      instance.configure(&block) if block_given?
      connections[name] = instance
    end

    def initialize_all
      connections.values.each(&:initialize_all)
    end

    def clean_db(confirm)
      connections.values.each {|i| i.clean_db(confirm)}
    end

    def reset_cached_variables
      connections.values.each(&:reset_cached_variables)
    end
  end
end
