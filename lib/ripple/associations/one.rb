require 'ripple/associations/instantiators'

module Ripple
  module Associations
    module One
      include Instantiators

      def to_a
        [self]
      end

      protected
      def instantiate_target(instantiator, attrs={})
        @_target = klass.send(instantiator, attrs)
        loaded
        @_target
      end
    end
  end
end
