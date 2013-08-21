require 'ripple/associations/proxy'
require 'ripple/associations/many'
require 'ripple/associations/linked'

module Ripple
  module Associations
    class ManyLinkedProxy < Proxy
      include Many
      include Linked

      def count
        # avoid having to load all documents by using our keys set instead
        keys.size
      end

      def <<(value)
        if loaded?
          new_target = @_target.concat(Array.wrap(value))
          replace new_target
        else
          @_reflection.verify_type!([value], @_owner)
          @_owner.robject.links << value.to_link(@_reflection.link_tag)
          appended_documents << value
          @keys = nil
        end

        self
      end

      def delete(value)
        load_target
        @_target.delete(value)
        replace @_target
        self
      end

      def reset
        @appended_documents = nil
        super
      end

      def loaded_documents
        (super + appended_documents).uniq
      end

      protected

      def find_target
        robjs = robjects

        robjs.delete_if do |robj|
          appended_documents.any? do |doc|
            doc.key == robj.key &&
            doc.class.bucket_name == robj.bucket.name
          end
        end

        appended_documents + robjs.map {|robj| klass.send(:instantiate, robj) }
      end

      def appended_documents
        @appended_documents ||= []
      end
    end
  end
end
