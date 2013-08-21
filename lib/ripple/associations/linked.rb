require 'ripple/associations'
require 'set'

module Ripple
  module Associations
    module Linked
      def replace(value)
        @_reflection.verify_type!(value, @_owner)
        @_owner.robject.links -= links
        Array.wrap(value).compact.each do |doc|
          @_owner.robject.links << doc.to_link(@_reflection.link_tag)
        end
        loaded
        @keys = nil
        @_target = value
      end

      def replace_links(value)
        @_owner.robject.links -= links
        Array(value).each do |link|
          @_owner.robject.links << link
        end
        reset
      end

      def keys
        @keys ||= Set.new(links.map { |l| l.key })
      end

      def reset
        super
        @keys = nil
      end

      def include?(document)
        return false unless document.respond_to?(:robject)

        # TODO: when we allow polymorphic assocations, this will have to change
        #       since @reflection.bucket_name will be '_' in that case.
        return false unless document.robject.bucket.name == @_reflection.bucket_name
        keys.include?(document.key)
      end

      protected
      def links
        @_owner.robject.links.select(&@_reflection.link_filter)
      end

      def robjects
        walk_result = begin
          @_owner.robject.walk(*Array(@_reflection.link_spec)).first || []
        rescue
          []
        end

        # We can get more robject results that we have links when there is conflict,
        # since link-walking returns the robjects for the union of all sibling links.
        # Here, we filter out robjects that should not be included.
        walk_result.select do |robject|
          links.include?(robject.to_link(@_reflection.link_tag))
        end
      end
    end
  end
end
