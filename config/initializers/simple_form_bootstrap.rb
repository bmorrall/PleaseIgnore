require 'base_error_notification'

module SimpleForm
  # Monkey Patches for Simple Form
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Monkey Patch Simple form to use custom error Notification
    def error_notification(options = {})
      BaseErrorNotification.new(self, options).render
    end

    alias input_without_error_prefix input

    # Monkey Path input to display error messages with Name
    def input(attribute_name, options = {}, &block)
      options = options.dup

      options[:error_prefix] ||=
        if object.class.respond_to?(:human_attribute_name)
          object.class.human_attribute_name(attribute_name.to_s)
        else
          attribute_name.to_s.humanize
        end

      input_without_error_prefix(attribute_name, options, &block)
    end
  end
end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input
    b.use :error, wrap_with: { tag: 'p', class: 'help-block fadeIn' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :horizontal_bootstrap,
                  tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-sm-9 col-md-7' do |ba|
      ba.use :input
      ba.use :error, full: true, wrap_with: { tag: 'p', class: 'help-block animated fadeIn' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :horizontal_bootstrap_wide,
                  tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-sm-8' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'p', class: 'help-block animated fadeIn' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.input_class = 'form-control'
  config.label_class = 'control-label'

  # Don't display required start for forms
  config.label_text = ->(label, _required, _explicit_label) { label }

  # Add Animated Error Classes
  config.error_notification_class = 'alert alert-danger animated fadeInDown'

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
