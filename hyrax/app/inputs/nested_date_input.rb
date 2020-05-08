class NestedDateInput < NestedAttributesInput

protected

  def build_components(attribute_name, value, index, options, parent=@builder.object_name)
    out = ''

    # Inherit required for fields validated in nested attributes
    required  = false
    if object.required?(:complex_date) and index == 0
      required = true
    end

    # Add remove elemnt only if element repeats
    repeats =options.delete(:repeats)
    repeats = true if repeats.nil?

    # --- description and date - single row
    out << "<div class='row'>"

    # description
    field = :description
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first
    field_class = class_for(attribute_name, field)
    field_requirements = requirements_for(attribute_name, field)

    date_options = DateService.new.select_all_options
    out << "  <div class='col-md-3'>"
    out << template.select_tag(field_name, template.options_for_select(date_options, field_value),
                               label: '', class: 'select form-control', prompt: 'choose type', id: field_id, data: {required: field_requirements, name: field, skip: true})
    out << '  </div>'

    # --- date
    field = :date
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first
    field_class = class_for(attribute_name, field)
    field_requirements = requirements_for(attribute_name, field)

    out << "  <div class='col-md-6'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id,
            data: { provide: 'datepicker', required: field_requirements, name: field }, required: required, class: field_class))
    out << '  </div>'

    # --- delete checkbox
    if repeats == true
      field_label = 'Date'
      out << "  <div class='col-md-3'>"
      out << destroy_widget(attribute_name, index, field_label, parent)
      out << '  </div>'
    end

    out << '</div>' # last row
    out
  end
end
