require 'ripple/associations/proxy'
require 'ripple/associations/many'
require 'ripple/associations/embedded'

module Ripple
  module Associations
    class ManyEmbeddedProxy < Proxy
      include Many
      include Embedded

      def <<(docs)
        load_target
        docs = Array.wrap(docs)
        @_reflection.verify_type!(docs, @_owner)
        assign_references(docs)
        @_target += docs
        self
      end

      def replace(docs)
        @_reflection.verify_type!(docs, @_owner)
        @_docs = docs.map { |doc| attrs = doc.respond_to?(:attributes_for_persistence) ? doc.attributes_for_persistence : doc }
        assign_references(docs)
        reset
        @_docs
      end

      protected
      def find_target
        (@_docs || []).map do |attrs|
          klass.instantiate(attrs).tap do |doc|
            assign_references(doc)
          end
        end
      end

    end
  end
end
