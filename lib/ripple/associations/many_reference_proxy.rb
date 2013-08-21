require 'ripple/associations/proxy'
require 'ripple/associations/many'

require 'set'

module Ripple
  module Associations
    class ManyReferenceProxy < Proxy
      include Many

      def <<(value)
        values = Array.wrap(value)
        @_reflection.verify_type!(values, @_owner)

        values.each {|v| assign_key(v) }
        load_target
        @_target.merge values

        self
      end

      def replace(value)
        @_reflection.verify_type!(value, @_owner)
        delete_all
        Array.wrap(value).compact.each do |doc|
          assign_key(doc)
        end
        loaded
        @keys = nil
        @_target = Set.new(value)
      end

      def delete_all
        load_target
        @_target.each do |e|
          delete(e)
        end
      end

      def delete(value)
        load_target
        assign_key(value, nil)
        @_target.delete(value)
      end

      def _target
        load_target
        @_target.to_a
      end

      def keys
        response = Ripple.client.search(klass.bucket_name, "#{key_name}: #{@_owner.key}")
        response = response['response'] if response.has_key? 'response'
        @keys ||= response["docs"].inject(Set.new) do |set, search_document|
          set << search_document["id"]
        end
      end

      def reset
        @keys = nil
        super
      end

      def include?(document)
        return false unless document.class.respond_to?(:bucket_name)

        return false unless document.class.bucket_name == @_reflection.bucket_name
        keys.include?(document.key)
      end

      def count
        if loaded?
          @_target.count
        else
          keys.count
        end
      end

      protected
      def find_target
        Set.new(klass.find(keys.to_a))
      end

      def key_name
        "#{@_owner.class.name.underscore}_key"
      end

      def assign_key(target, key=@_owner.key)
        if target.new_record?
          target.send("#{key_name}=", key)
        else
          target.update_attribute(key_name, key)
        end
      end
    end
  end
end
