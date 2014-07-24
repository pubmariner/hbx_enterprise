inputs = %w[
  DateTimeInput
  FileInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]

#  CollectionSelectInput
#  GroupedCollectionSelectInput

inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize

  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end

  Object.const_set(input_type, new_class)
end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # config.boolean_style = :nested
  # config.input_class = 'form-control'
  config.label_class = 'col-sm-2 control-label'

   config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

   config.wrappers :bstrap_hz_large_xx, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-10' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :bstrap_hz_large, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-8' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

   config.wrappers :bstrap_hz_medium, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-6' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

   config.wrappers :bstrap_hz_small, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-4' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

   config.wrappers :bstrap_hz_small_xx, tag: 'div', class: 'form-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :label
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-2' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :group, tag: 'div', class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input, wrap_with: { class: "input-group" }
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
  end

  config.wrappers :input_horizontal, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|

    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder

    b.optional :pattern
    b.optional :readonly

    b.optional :label, wrap_with: { class: 'col-sm-2 control-label' }
    b.use :input, wrap_with: { tag: 'div', class: 'col-sm-10' }
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  config.wrappers :inline_checkbox1, :tag => 'div', :class => 'form-group', :error_class => 'error' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: :div, class: 'col-sm-offset-2 col-sm-10' do |ba|
      ba.wrapper tag: :div, class: "checkbox" do |bb|
        # bb.wrapper tag: 'label', class: 'checkbox primary' do |bc|
          bb.use :input, wrap_with: { input_html: { type: 'checkbox'}, tag: 'label', class: 'checkbox primary' }
          bb.optional :label_text
        # end
      end
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :inline_checkbox, :tag => 'div', :class => 'form-group', :error_class => 'error' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: :div, class: 'col-sm-offset-2' do |ba|
      ba.wrapper tag: :label, wrap_with: { class: 'checkbox primary' } do |bb|
        bb.use :input #, input_html: { type: 'checkbox', data_toggle: 'checkbox'}
        # bb.optional :label_text
      end
    end
    b.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    b.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
  end


  config.wrappers :checkbox, :tag => 'div', wrap_with: { tag: :div, :class => 'form-group'}, :error_class => 'error' do |b|
    b.wrapper tag: :div do |ba|
      ba.use :input
    end
  end

  config.wrappers :checkbox1, :tag => 'div', :class => 'form-group', :error_class => 'error' do |b|
    b.wrapper tag: :div do |ba|
      ba.use :label_input, wrap_with: { input_html: {  }}
    end
  end

  config.wrappers :prepend, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-group' do |prepend|
    prepend.use :label , wrap_with: { class: 'input-group-addon' } ###Please note setting class here fro the label does not currently work (let me know if you know a workaround as this is the final hurdle)
        prepend.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
    end
  end

  config.wrappers :append, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-group' do |prepend|
        prepend.use :input
    prepend.use :label , wrap_with: { class: 'input-group-addon' } ###Please note setting class here fro the label does not currently work (let me know if you know a workaround as this is the final hurdle)
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
    end
  end

  config.wrappers :checkbox, tag: :div, class: "checkbox", error_class: "has-error" do |b|

    # Form extensions
    b.use :html5

    # Form components
    b.wrapper tag: :label do |ba|
      ba.use :input
      ba.use :label_text
    end

    b.use :hint,  wrap_with: { tag: :p, class: "help-block" }
    b.use :error, wrap_with: { tag: :span, class: "help-block text-danger" }
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com/)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
