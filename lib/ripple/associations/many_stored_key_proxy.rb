require 'ripple/associations/proxy'
require 'ripple/associations/many'

module Ripple
  module Associations
    class ManyStoredKeyProxy < Proxy
      include Many

      def count
        keys.size
      end

      def <<(value)
        @_reflection.verify_type!([value], @_owner)

        raise "Unable to append if the document isn't first saved." if value.new_record?
        load_target
        @_target << value
        keys << value.key

        self
      end

      def replace(value)
        @_reflection.verify_type!(value, @_owner)

        reset_owner_keys
        value.each { |doc| self << doc }
        @_target = value
        loaded
      end

      def delete(value)
        keys.delete(value.key)
        self
      end

      def keys
        if @_owner.send(keys_name).nil?
          reset_owner_keys
        end

        @_owner.send(keys_name)
      end

      def reset
        super
        self.owner_keys = @_owner.robject.data && @_owner.robject.data[keys_name] || []
      end

      def include?(document)
        return false unless document.respond_to?(:robject)
        return false unless document.robject.bucket.name == @_reflection.bucket_name
        keys.include?(document.key)
      end

      def reset_owner_keys
        self.owner_keys = []
      end

      protected
      def find_target
        klass.find(keys.to_a)
      end

      def keys_name
        (@_reflection.options[:foreign_key] || "#{@_reflection.name.to_s.singularize}_keys").to_s
      end

      def owner_keys=(new_keys)
        @_owner.send("#{keys_name}=", @_owner.class.properties[keys_name].type.new(new_keys))
      end
    end
  end
end
