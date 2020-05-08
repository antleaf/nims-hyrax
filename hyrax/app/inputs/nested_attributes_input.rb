class NestedAttributesInput < MultiValueInput

  def input(wrapper_options)
    super
  end

  def nested_input(wrapper_options, values, parent=@builder.object_name)
    @rendered_first_element = false
    input_html_classes.unshift('string')
    input_html_options[:name] ||= "#{parent}[#{attribute_name}][]"
    input_html_options[:repeats] = false
    nested_outer_wrapper do
      buffer_each(values) do |value, index|
        nested_inner_wrapper do
          build_field(value, index, parent)
        end
      end
    end
  end

  protected

    def nested_outer_wrapper
      "    <ul class=\"inner-listing\">\n        #{yield}\n      </ul>\n"
    end

    def nested_inner_wrapper
      <<-HTML
          <li class="field-wrapper">
            #{yield}
          </li>
        HTML
    end

    def build_field(value, index, parent=@builder.object_name)
      options = input_html_options.dup
      if !value.kind_of? ActiveTriples::Resource
        association = @builder.object.model.send(attribute_name)
        value = association.build
      end
      # if value.kind_of? ActiveTriples::Resource
      options[:name] = name_for(attribute_name, index, 'hidden_label'.freeze, parent)
      options[:id] = id_for(attribute_name, index, 'hidden_label'.freeze, parent)

      if value.new_record?
        build_options_for_new_row(attribute_name, index, options)
      else
        build_options_for_existing_row(attribute_name, index, value, options)
      end
      # end

      options[:required] = nil if @rendered_first_element

      options[:class] ||= []
      options[:class] += ["#{input_dom_id} form-control multi-text-field"]
      options[:'aria-labelledby'] = label_id

      @rendered_first_element = true

      out = ''
      out << build_components(attribute_name, value, index, options, parent)
      out << hidden_id_field(value, index, parent) unless value.new_record?
      out
    end

    def destroy_widget(attribute_name, index, field_label="field", parent=@builder.object_name)
      out = ''
      out << hidden_destroy_field(attribute_name, index, parent)
      out << "    <button type=\"button\" class=\"btn btn-link remove\">"
      out << "      <span class=\"glyphicon glyphicon-remove\"></span>"
      out << "      <span class=\"controls-remove-text\">Remove</span>"
      out << "      <span class=\"sr-only\"> previous <span class=\"controls-field-name-text\"> #{field_label}</span></span>"
      out << "    </button>"
      out
    end

    def hidden_id_field(value, index, parent=@builder.object_name)
      name = id_name_for(attribute_name, index, parent)
      id = id_for(attribute_name, index, 'id'.freeze, parent)
      hidden_value = value.new_record? ? '' : value.rdf_subject
      @builder.hidden_field(attribute_name, name: name, id: id, value: hidden_value, data: { id: 'remote' })
    end

    def hidden_destroy_field(attribute_name, index, parent=@builder.object_name)
      name = destroy_name_for(attribute_name, index, parent)
      id = id_for(attribute_name, index, '_destroy'.freeze, parent)
      hidden_value = false
      @builder.hidden_field(attribute_name, name: name, id: id,
        value: hidden_value, data: { destroy: true }, class: 'form-control remove-hidden')
    end

    def build_options_for_new_row(_attribute_name, _index, options)
      options[:value] = ''
    end

    def build_options_for_existing_row(_attribute_name, _index, value, options)
      options[:value] = value.rdf_label.first || "Unable to fetch label for #{value.rdf_subject}"
    end

    def name_for(attribute_name, index, field, parent=@builder.object_name)
      "#{parent}[#{attribute_name}_attributes][#{index}][#{field}][]"
    end

    def id_name_for(attribute_name, index, parent=@builder.object_name)
      singular_input_name_for(attribute_name, index, 'id', parent)
    end

    def destroy_name_for(attribute_name, index, parent=@builder.object_name)
      singular_input_name_for(attribute_name, index, '_destroy', parent)
    end

    def singular_input_name_for(attribute_name, index, field, parent=@builder.object_name)
      "#{parent}[#{attribute_name}_attributes][#{index}][#{field}]"
    end

    def id_for(attribute_name, index, field, parent=@builder.object_name)
      [parent, "#{attribute_name}_attributes", index, field].join('_'.freeze)
    end

    def class_for(attribute_name, field, model_class=@builder.object.class.model_class)
      requirements = model_class.requirements_for(attribute_name)
      if (requirements[:required] && requirements[:required].flatten.include?(field.to_s)) ||
         (requirements[:conditional] && requirements[:conditional][field].present?)
        'required-if'
      else
        ''
      end
    end

    def requirements_for(attribute_name, field, model_class=@builder.object.class.model_class)
      requirements = model_class.requirements_for(attribute_name)
      if requirements[:required] && requirements[:required].flatten.include?(field.to_s)
        'any'
      elsif requirements[:conditional] && requirements[:conditional][field].present?
        requirements[:conditional][field].join(';')
      end
    end
end
