class NestedEventAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  private
  def attribute_value_to_html(value)
    value = JSON.parse(value)
    html = []
    value.each do |v|
      vals = []
      unless v.dig('title').blank?
        label = 'Title'
        val = v['title'][0]
        vals << [label, val]
      end
      unless v.dig('place').blank?
        label = 'Location'
        val = v['place'][0]
        vals << [label, val]
      end
      unless v.dig('start_date').blank?
        label = 'Start date'
        val = v['start_date'][0]
        vals << [label, val]
      end
      unless v.dig('end_date').blank?
        label = 'End date'
        val = v['end_date'][0]
        vals << [label, val]
      end
      unless v.dig('invitation_status').blank?
        label = 'Invitation status'
        val = v['invitation_status'][0]
        vals << [label, val]
      end
      html << vals if vals.any?
    end
    html_out = ''
    unless html.blank?
      html_out = '<table class="table nested-table"><tbody>'
      html.each do |vals|
        vals.each_with_index do |h, index|
          if (index + 1) == vals.size
            html_out += '<tr class="end">'
          else
            html_out += '<tr>'
          end
          html_out += "<th>#{h[0]}</th><td>#{h[1]}</td></tr>"
        end
      end
      html_out += '</tbody></table>'
    end
    %(#{html_out})
  end
end
