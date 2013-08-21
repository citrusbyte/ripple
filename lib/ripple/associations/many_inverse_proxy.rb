require 'ripple/associations/proxy'
require 'ripple/associations/many'

module Ripple
  module Associations
    class ManyInverseProxy < Proxy
      include Many

      def count
        keys.size
      end

      def <<(value)
        @_reflection.verify_type!([value], @_owner)
        associate(value)
        self
      end

      def replace(value)
        @_reflection.verify_type!(value, @_owner)

        (self - value).each {|doc| disassociate(doc) }
        (value - self).each {|doc| associate(doc) }
        loaded
      end

      def delete(value)
        disassociate(value)
        self
      end

      def keys
        @keys ||= @_target.map(&:key)
      end

      def include?(document)
        return false unless document.respond_to?(:robject)
        return false unless document.robject.bucket.name == @_reflection.bucket_name
        keys.include?(document.key)
      end

      protected

      def find_target
        _owner.key.blank? ? [] : klass.find_by_index(foreign_key, _owner.key)
      end

      def foreign_key
        return @foreign_key unless @foreign_key.blank?

        @foreign_key = @_reflection.options[:of_key].to_s # The key used to build the association from the other object

        if @foreign_key.blank?
          foreign_association = klass.associations[@_reflection.options[:of].to_s]
          @foreign_key = foreign_association && foreign_association.options[:foreign_key].to_s
        end

        @foreign_key || "#{_owner.class.to_s.downcase.singularize}_keys"
      end

      # Handle the disassociation between a parent and a child
      # Here is the place to clean keys, destroy objects, etc.
      def disassociate(document)
        document.send("#{foreign_key}=", nil)
        @_target.delete document
        @keys.delete document.key unless @keys.nil?

        # TODO: support cascade_all :delete
        if @_reflection.options[:destroy_on_disassociate]
          document.destroy
        else
          # TODO: support saves
          document.save
        end
      end

      def associate(document)
        raise "Unable to associate if the document isn't first saved." if document.new_record?

        document.send("#{foreign_key}=", @_owner.key)
        # TODO: support saves
        document.save

        load_target
        @_target << document
        @keys << document.key unless @keys.nil?
      end

    end
  end
end
