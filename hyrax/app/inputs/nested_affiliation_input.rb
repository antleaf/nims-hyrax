class NestedAffiliationInput < NestedAttributesInput

protected

  def build_components(attribute_name, value, index, options, parent=@builder.object_name)
    out = ''

    # Inherit required for fields validated in nested attributes
    required  = false
    if object.required?(:complex_person) and index == 0
      required = true
    end

    # Add remove element only if element repeats
    repeats =options.delete(:repeats)
    repeats = true if repeats.nil?

    parent_attribute = name_for(attribute_name, index, '', parent)[0..-5]

    # --- job_title
    out << "<div class='row'>"
    field = :job_title
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first
    field_class = class_for(attribute_name, field)
    field_requirements = requirements_for(attribute_name, field)

    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_id, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
                               options.merge(value: field_value, name: field_name, id: field_id, required: false, class: field_class, data: {required: field_requirements, name: field}))
    out << '  </div>'
    out << '</div>'

    # --- complex_organization
    field = :complex_organization
    field_value = value.send(field)
    if field_value.blank?
      value.complex_organization.build
      field_value = value.send(field)
    end
    nested_fields = NestedOrganizationInput.new(@builder, field, nil, :multi_value, {})
    out << "<div class='inner-nested'>"
    out << "<div class='form-group'>"
    # out << "  <label class='control-label optional' for='dataset_complex_orgnaization'>Organization</label>"
    out << nested_fields.nested_input({:class=>"form-control", :repeats => false}, field_value, parent_attribute)
    out << "</div>"
    # out << "  <button type='button' class='btn btn-link add'>"
    # out << "    <span class='glyphicon glyphicon-plus'></span>"
    # out << "    <span class='controls-add-text'>Add another identifier</span>"
    # out << "  </button>"
    out << "</div>" # row

    # last row
    # --- delete checkbox
    if repeats == true
      out << "<div class='row'>"
      field_label = 'Affiliation'
      out << "  <div class='col-md-12'>"
      out << destroy_widget(attribute_name, index, field_label, parent)
      out << '  </div>'
      out << '</div>' # last row
    end

    out
  end
end
