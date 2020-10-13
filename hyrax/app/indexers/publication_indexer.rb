# Generated via
#  `rails generate hyrax:work Publication`
class PublicationIndexer < NgdrIndexer
  # Custom indexers for publication model
  include ComplexField::DateIndexer
  include ComplexField::IdentifierIndexer
  include ComplexField::PersonIndexer
  include ComplexField::RightsIndexer
  include ComplexField::VersionIndexer
  include ComplexField::EventIndexer
  include ComplexField::SourceIndexer

  def self.facet_fields
    super.tap do |fields|
      fields << Solrizer.solr_name('specimen_set', :stored_searchable)
      fields << Solrizer.solr_name('place', :facetable)
      fields.concat ComplexField::DateIndexer.date_facet_fields
      fields.concat ComplexField::PersonIndexer.person_facet_fields
      fields.concat ComplexField::RightsIndexer.rights_facet_fields
      fields.concat ComplexField::EventIndexer.event_facet_fields
      fields.concat ComplexField::SourceIndexer.source_facet_fields
    end
  end

  def self.search_fields
    super.tap do |fields|
      fields << Solrizer.solr_name('specimen_set', :stored_searchable)
      fields << Solrizer.solr_name('issue', :stored_searchable)
      fields << Solrizer.solr_name('place', :stored_searchable)
      fields << Solrizer.solr_name('table_of_contents', :stored_searchable)
      fields << Solrizer.solr_name('first_published_url', :stored_searchable)
      fields << Solrizer.solr_name('doi', :stored_searchable)
      fields.concat ComplexField::DateIndexer.date_search_fields
      fields.concat ComplexField::IdentifierIndexer.identifier_search_fields
      fields.concat ComplexField::PersonIndexer.person_search_fields
      fields.concat ComplexField::RightsIndexer.rights_search_fields
      fields.concat ComplexField::EventIndexer.event_search_fields
      fields.concat ComplexField::SourceIndexer.source_search_fields
    end
  end

  def self.show_fields
    super.tap do |fields|
      fields << Solrizer.solr_name('specimen_set', :stored_searchable)
      fields << Solrizer.solr_name('issue', :stored_searchable)
      fields << Solrizer.solr_name('place', :stored_searchable)
      fields << Solrizer.solr_name('table_of_contents', :stored_searchable)
      fields.concat ComplexField::DateIndexer.date_show_fields
      fields.concat ComplexField::IdentifierIndexer.identifier_show_fields
      fields.concat ComplexField::PersonIndexer.person_show_fields
      fields.concat ComplexField::RightsIndexer.rights_show_fields
      fields.concat ComplexField::EventIndexer.event_show_fields
      fields.concat ComplexField::SourceIndexer.source_show_fields
    end
  end

end
