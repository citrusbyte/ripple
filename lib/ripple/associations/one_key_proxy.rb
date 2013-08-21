require 'ripple/associations/proxy'
require 'ripple/associations/one'

module Ripple
  module Associations
    class OneKeyProxy < Proxy
      include One

      def replace(doc)
        @_reflection.verify_type!(doc, _owner)

        reset_previous_target_key_delegate
        assign_new_target_key_delegate(doc)

        loaded
        @_target = doc
      end

      def find_target
        klass.find(_owner.key)
      end

      protected
      def instantiate_target(instantiator, attrs={})
        @_target = super
        @_target.key = _owner.key
        @_target
      end

      private
      def reset_previous_target_key_delegate
        @_target.key_delegate = @_target if @_target
      end

      def assign_new_target_key_delegate(doc)
        doc.class.send(:include, Ripple::Associations::KeyDelegator) unless doc.class.include?(Ripple::Associations::KeyDelegator)
        _owner.key_delegate = doc.key_delegate = _owner
      end

    end

    module KeyDelegator
      attr_accessor :key_delegate

      def key_delegate
        @key_delegate || self
      end

      def key
        self === key_delegate ? super : key_delegate.key
      end

      def key=(value)
        self === key_delegate ? super(value) : key_delegate.key = value
      end
    end
  end
end
