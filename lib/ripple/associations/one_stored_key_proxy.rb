require 'ripple/associations/proxy'
require 'ripple/associations/one'

module Ripple
  module Associations
    class OneStoredKeyProxy < Proxy
      include One

      def replace(value)
        @_reflection.verify_type!(value, _owner)

        if value
          assign_key(value.key)
        else
          assign_key(nil)
        end

        @_target = value
        loaded
      end

      protected

      def key
        @_owner.send(key_name)
      end

      def assign_key(value)
        @_owner.send("#{key_name}=", value)
      end

      def key_name
        @_reflection.options[:foreign_key] || "#{@_reflection.name}_key"
      end

      def find_target
        return nil if key.blank?

        klass.find(key)
      end
    end
  end
end
