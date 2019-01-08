module ComplexField
  module CustomPropertyIndexer
    def generate_solr_document
      super.tap do |solr_doc|
        index_custom_property(solr_doc)
      end
    end

    def index_custom_property(solr_doc)
      solr_doc[Solrizer.solr_name('custom_property', :displayable)] = object.custom_property.to_json
      object.custom_property.each do |c|
        unless (c.label.first.blank? or c.description.first.blank?)
          fld_name = Solrizer.solr_name("custom_property_#{c.label.first.downcase.tr(' ', '_')}", :stored_searchable)
          solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
          solr_doc[fld_name] << c.description.reject(&:blank?)
          solr_doc[fld_name].flatten!
        end
      end
    end
  end
end