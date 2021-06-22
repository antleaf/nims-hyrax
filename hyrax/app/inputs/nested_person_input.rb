class NestedPersonInput < NestedAttributesInput

protected

  def build_components(attribute_name, value, index, options, parent=@builder.object_name)
    out = ''

    # Inherit required for fields validated in nested attributes
    required  = false
    if object.required?(:complex_person) and index == 0
      required = true
    end

    # Add remove elemnt only if element repeats
    repeats = options.delete(:repeats)
    repeats = true if repeats.nil?

    parent_attribute = name_for(attribute_name, index, '', parent)[0..-5]

    # --- last_name
    field = :last_name
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, I18n.t('ngdr.fields.last_name'), required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required, placeholder: "Alphabets"))
    out << '  </div>'
    out << '</div>' # row

    # --- first_name
    field = :first_name
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, I18n.t('ngdr.fields.first_name'), required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required, placeholder: "Alphabets"))
    out << '  </div>'
    out << '</div>' # row

    # --- name
    field = :name
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, I18n.t('ngdr.fields.full_name'), required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required, placeholder: "SURNAME, Given Names"))
    out << '  </div>'
    out << '</div>' # row

    # --- role
    role_options = RoleService.new.select_all_options
    field = :role
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << template.select_tag(field_name, template.options_for_select(role_options, field_value),
        prompt: 'Select role played', label: '', class: 'select form-control', id: field_id, required: required)
    out << '  </div>'
    out << '</div>' # row

    # --- orcid
    field = :orcid
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required, placeholder: "https://orcid.org/0000-0000-0000-0000"))
    out << '  </div>'
    out << '</div>' # row

    # --- organization
    field = :organization
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required, placeholder: "Alphabets, unabbreviated"))
    out << '  </div>'
    out << '</div>' # row

    # --- sub_organization
    field = :sub_organization
    field_name = name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field).first

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-9'>"
    out << @builder.text_field(field_name,
        options.merge(value: field_value, name: field_name, id: field_id, required: required))
    out << '  </div>'
    out << '</div>' # row

    # --- corresponding_author
    field = :corresponding_author
    field_name = singular_input_name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = if value.send(field)
                    value.send(field).first || 0
                  else
                    1
                  end
    field_checked = field_value.to_i.zero? ? false : true

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, I18n.t('ngdr.fields.corresponding_author'), required: required)
    out << '  </div>'

    out << "  <div class='col-md-2'>"
    out << @builder.check_box(field_name,
      options.merge(checked: field_checked, value: field_value, name: field_name, id: field_id, required: required, class: 'corresponding_author'))
    out << '  </div>'
    out << '</div>' # row

    # --- display_order
    field = :display_order
    field_name = singular_input_name_for(attribute_name, index, field, parent)
    field_id = id_for(attribute_name, index, field, parent)
    field_value = value.send(field)&.first&.to_i

    out << "<div class='row'>"
    out << "  <div class='col-md-3'>"
    out << template.label_tag(field_name, field.to_s.humanize, required: required)
    out << '  </div>'

    out << "  <div class='col-md-3'>"
    out << @builder.number_field(field_name,
      options.merge(value: field_value || 0, name: field_name, id: field_id, required: required))
    out << '  </div>'
    out << '</div>' # row

    # --- complex_identifier
    #field = :complex_identifier
    #field_value = value.send(field)
    #if field_value.blank?
    #  value.complex_identifier.build
    #  field_value = value.send(field)
    #end
    #nested_fields = NestedIdentifierInput.new(@builder, field, nil, :multi_value, {})
    #out << "<div class='inner-nested'>"
    #out << "<div class='form-group'>"
    #out << "  <label class='control-label optional' for='dataset_#{field.to_s}'>Identifier</label>"
    #out << nested_fields.nested_input({:class=>"form-control", :repeats => false}, field_value, parent_attribute)
    #out << "</div>"
    # out << "  <button type='button' class='btn btn-link add'>"
    # out << "    <span class='glyphicon glyphicon-plus'></span>"
    # out << "    <span class='controls-add-text'>Add another identifier</span>"
    # out << "  </button>"
    #out << "</div>" # row

    # --- complex_affiliation
    #field = :complex_affiliation
    #field_value = value.send(field)
    #if field_value.blank?
    #  value.complex_affiliation.build
    #  field_value = value.send(field)
    #end
    #nested_fields = NestedAffiliationInput.new(@builder, field, nil, :multi_value, {})
    #out << "<div class='inner-nested'>"
    #out << "<div class='form-group'>"
    #out << "  <label class='control-label optional' for='dataset_#{field.to_s}'>Affiliation</label>"
    #out << nested_fields.nested_input({:class=>"form-control", :repeats => false}, field_value, parent_attribute)
    #out << "</div>"
    # out << "  <button type='button' class='btn btn-link add'>"
    # out << "    <span class='glyphicon glyphicon-plus'></span>"
    # out << "    <span class='controls-add-text'>Add another affiliation</span>"
    # out << "  </button>"
    #out << "</div>" # row

    # last row
    # --- delete checkbox
    if repeats == true
      field_label = 'Person'
      out << "<div class='row'>"
      out << "  <div class='col-md-3'>"
      out << destroy_widget(attribute_name, index, field_label, parent)
      out << '  </div>'
      out << '</div>' # last row
    end

    out
  end
end
