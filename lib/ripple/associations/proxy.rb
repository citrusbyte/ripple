require 'ripple/associations'

module Ripple
  module Associations
    class Proxy
      alias :proxy_respond_to? :respond_to?
      alias :proxy_extend :extend

      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

      attr_reader :_owner, :_reflection, :_target

      alias :proxy_owner :_owner
      alias :proxy_target :_target
      alias :proxy_reflection :_reflection

      delegate :klass, :to => :proxy_reflection
      delegate :options, :to => :proxy_reflection
      delegate :collection, :to => :klass

      def initialize(owner, reflection)
        @_owner, @_reflection = owner, reflection
        Array.wrap(reflection.options[:extend]).each { |ext| proxy_extend(ext) }
        reset
      end

      def inspect
        load_target
        _target.inspect
      end

      def loaded?
        @loaded
      end

      def loaded
        @loaded = true
      end

      def nil?
        load_target
        _target.nil?
      end

      def blank?
        load_target
        _target.blank?
      end

      def present?
        load_target
        _target.present?
      end

      def reload
        reset
        load_target
        self unless _target.nil?
      end

      def replace(v)
        raise NotImplementedError
      end

      def reset
        @loaded = false
        @_target = nil
      end

      def respond_to?(*args)
        proxy_respond_to?(*args) || (load_target && _target.respond_to?(*args))
      end

      def send(method, *args, &block)
        if proxy_respond_to?(method)
          super
        else
          load_target
          _target.send(method, *args, &block)
        end
      end

      def ===(other)
        load_target
        other === _target
      end

      def loaded_documents
        loaded? ? Array.wrap(_target) : []
      end

      def has_changed_documents?
        loaded_documents.any? { |doc| doc.changed? }
      end

      protected
      def method_missing(method, *args, &block)
        load_target

        if block_given?
          _target.send(method, *args)  { |*block_args| block.call(*block_args) }
        else
          _target.send(method, *args)
        end
      end

      def load_target
        @_target = find_target unless loaded?
        loaded
        @_target
      end

      def find_target
        raise NotImplementedError
      end
    end
  end
end
