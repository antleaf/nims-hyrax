class NgdrIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def self.facet_fields
    # solr fields that will be treated as facets
    [
      # core and basic metadata fields - not interested in these
      # Solrizer.solr_name('creator', :facetable),
      # Solrizer.solr_name('contributor', :facetable),
      # Solrizer.solr_name('based_near_label', :facetable),

      # system fields
      Solrizer.solr_name('file_format', :facetable),
      Solrizer.solr_name('human_readable_type', :facetable),
      Solrizer.solr_name('member_of_collections', :symbol),

      # core and basic metadata fields
      Solrizer.solr_name('keyword', :facetable),
      Solrizer.solr_name('language', :facetable),
      Solrizer.solr_name('publisher', :facetable),
      Solrizer.solr_name('resource_type', :facetable),
      Solrizer.solr_name('subject', :facetable),
    ]
  end

  def self.search_fields
    # solr fields that will be used for a search
    [
      Solrizer.solr_name('title', :stored_searchable),
      Solrizer.solr_name('description', :stored_searchable),
      Solrizer.solr_name('keyword', :stored_searchable),
      Solrizer.solr_name('subject', :stored_searchable),
      Solrizer.solr_name('publisher', :stored_searchable),
      Solrizer.solr_name('language', :stored_searchable),
      Solrizer.solr_name('date_uploaded', :stored_searchable),
      Solrizer.solr_name('date_modified', :stored_searchable),
      Solrizer.solr_name('date_created', :stored_searchable),
      Solrizer.solr_name('rights_statement', :stored_searchable),
      Solrizer.solr_name('license', :stored_searchable),
      Solrizer.solr_name('resource_type', :stored_searchable),
      Solrizer.solr_name('format', :stored_searchable),
      Solrizer.solr_name('identifier', :stored_searchable),
      Solrizer.solr_name('place', :stored_searchable),
      Solrizer.solr_name('status', :stored_searchable),
      Solrizer.solr_name('issue', :stored_searchable),
      Solrizer.solr_name('licensed_date', :stored_searchable)
    ]
  end

  def self.show_fields
    # solr fields that will be used to display results on the record page
    [
      # Solrizer.solr_name('creator', :stored_searchable),
      # Solrizer.solr_name('contributor', :stored_searchable),
      # Solrizer.solr_name('based_near_label', :stored_searchable),
      Solrizer.solr_name('title', :stored_searchable),
      Solrizer.solr_name('description', :stored_searchable),
      Solrizer.solr_name('keyword', :stored_searchable),
      Solrizer.solr_name('subject', :stored_searchable),
      Solrizer.solr_name('publisher', :stored_searchable),
      Solrizer.solr_name('language', :stored_searchable),
      Solrizer.solr_name('date_uploaded', :stored_searchable),
      Solrizer.solr_name('date_modified', :stored_searchable),
      Solrizer.solr_name('date_created', :stored_searchable),
      Solrizer.solr_name('rights_statement', :stored_searchable),
      Solrizer.solr_name('license', :stored_searchable),
      Solrizer.solr_name('resource_type', :stored_searchable),
      Solrizer.solr_name('format', :stored_searchable),
      Solrizer.solr_name('identifier', :stored_searchable),
      Solrizer.solr_name('place', :stored_searchable),
      Solrizer.solr_name('status', :stored_searchable),
      Solrizer.solr_name('issue', :stored_searchable),
      Solrizer.solr_name('licensed_date', :stored_searchable)
    ]
  end
end
