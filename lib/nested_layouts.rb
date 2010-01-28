module ActionView #:nodoc:
  module Helpers #:nodoc:
    module NestedLayoutsHelper

      # Wrap part of the template into layout.
      # All layout files must be in app/views/layouts.
      def inside_layout(layout, &block)
        layout_template = @template.view_paths.find_template(layout.to_s =~ /layouts\// ? layout : "layouts/#{layout}", :html)
        @template.instance_variable_set('@content_for_layout', capture(&block))
        
        # Long method is long!
        current_layout_path = @template.instance_variable_get(:@_current_render).
        instance_variable_get(:@_memoized_relative_path).first

        next_layout = @template.view_paths.find_template("layouts/#{layout}", :html)
        
        # Is there a way to calculate this?
        next_layout_path = Dir["app/views/layouts/#{layout}.*"].first
        
        raise NestedLayouts::RecursionError, "You cannot render the layout \"#{layout}\" inside itself! Doing so would break the space time continuum!" if next_layout_path == current_layout_path
        
        concat(@template.render(:file => next_layout, :user_full_path => true), binding)
      end

      # Wrap part of the template into inline layout.
      # Same as +inside_layout+ but takes layout template content rather than layout template name.
      def inside_inline_layout(template_content, &block)
        @template.instance_variable_set('@content_for_layout', capture(&block))
        concat( @template.render(:inline => template_content) )
      end
    end
  end
end

module NestedLayouts
  class RecursionError < Exception; end
end

ActionView::Base.send :include, ActionView::Helpers::NestedLayoutsHelper