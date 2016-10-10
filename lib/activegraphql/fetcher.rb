require 'activegraphql/support/fancy'
require 'retriable'

module ActiveGraphQL
  class Fetcher < Support::Fancy
    attr_accessor :config, :klass, :action, :params, :query

    class Error < StandardError; end

    def initialize(attrs)
      super(attrs)
    end

    def query
      @query ||= Query.new(config: config, action: action, params: params)
    end

    def in_locale(locale)
      query.locale = locale if locale.present?
      self
    end

    def fetch(*graph)
      response = query_call(*graph)

      return if response.blank?

      case response
      when Hash
        klass.new(response)
      when Array
        response.map { |h| klass.new(h) }
      else
        raise Error, "Unexpected response for query: #{response}"
      end
    end

    def query_call(*graph)
      Retriable.retriable(retriable_config) { query.call(*graph) }
    end

    def retriable_config
      # use defaults if retriable config is not a hash
      # (ie. retriable: true | false)
      @retriable_config ||=
        if config[:retriable].is_a?(Hash)
          default_retriable_options.merge(config[:retriable])
        else
          default_retriable_options
        end
    end

    # Defaults are:
    #  - { tries: 1 } if there's no retriable config.
    #  - {} if the config is enabled but with no hash (it will use the defaults
    #    from Retriable)
    def default_retriable_options
      @default_retriable_options ||=
        config[:retriable].blank? ? { tries: 1 } : {}
    end
  end
end
