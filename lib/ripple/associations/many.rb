require 'ripple/associations'

module Ripple
  module Associations
    module Many
      include Instantiators

      def to_ary
        load_target
        Array === _target ? _target.to_ary : Array.wrap(_target)
      end

      def count
        load_target
        _target.size
      end

      def reset
        super
        @_target = []
      end

      def <<(value)
        raise NotImplementedError
      end

      alias_method :push, :<<
      alias_method :concat, :<<

      protected
      def instantiate_target(instantiator, attrs={})
        doc = klass.send(instantiator, attrs)
        self << doc
        doc
      end
    end
  end
end
