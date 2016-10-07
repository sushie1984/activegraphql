module ActiveGraphQL
  module Helpers
    module ModelHelper

      def map_to_s(conditions = {})
        return '' if conditions.blank?
        return conditions if conditions.is_a?(String)
        return '' if !conditions.is_a?(Hash)
        conditions.to_a.collect{ |x| x.join(' ')}.join(', ')
      end

    end
  end
end
