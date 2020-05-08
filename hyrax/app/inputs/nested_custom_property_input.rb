class NestedCustomPropertyInput < NestedAttributesInput

protected

  def build_components(attribute_name, value, index, options, parent=@builder.object_name)
    out = ''

    # Inherit required for fields validated in nested attributes
    required  = false
    if object.required?(:custom_property) and index == 0
      required = true
    end

    # Add remove elemnt only if element repeats
    repeats = options.delete(:repeats)
    repeats = true if repeats.nil?

    # --- label
    field = :label
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first
    field_class = class_for(attribute_name, field)
    field_requirements = requirements_for(attribute_name, field)


    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_id, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
                               options.merge(value: field_value, name: field_name, id: field_id, required: required, class: field_class, data: {required: field_requirements, name: field}))
    out << '  </div>'
    out << '</div>' # row

    # last row
    out << "<div class='row'>"

    # --- description
    field = :description
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first
    field_class = class_for(attribute_name, field)
    field_requirements = requirements_for(attribute_name, field)

    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_id, field.to_s.humanize, required: false)
    out << '  </div>'

    out << "  <div class='col-md-6'>"
    out << @builder.text_field(field_name,
                               options.merge(value: field_value, name: field_name, id: field_id, class: field_class, data: {required: field_requirements, name: field}))
    out << '  </div>'

    # --- delete checkbox
    if repeats == true
      field_label = 'Additional metadata'
      out << "  <div class='col-md-3'>"
      out << destroy_widget(attribute_name, index, field_label, parent)
      out << '  </div>'
    end

    out << '</div>' # last row
    out
  end
end
