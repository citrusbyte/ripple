require 'ripple/associations/proxy'
require 'ripple/validations/associated_validator'

module Ripple
  module Associations
    module Embedded

      def initialize(*args)
        super
        lazy_load_validates_associated
      end

      protected

      def lazy_load_validates_associated
        return if @_owner.class.validators_on(@_reflection.name).any? {|v| Ripple::Validations::AssociatedValidator === v}
        @_owner.class.validates @_reflection.name, :associated => true
      end

      def assign_references(docs)
        Array.wrap(docs).each do |doc|
          next unless doc.respond_to?(:_parent_document=)
          doc._parent_document = _owner
        end
      end

      def instantiate_target(*args)
        doc = super
        assign_references(doc)
        doc
      end

    end
  end
end
