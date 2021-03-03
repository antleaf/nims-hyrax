module ComplexField
  module DateIndexer
    def generate_solr_document
      super.tap do |solr_doc|
        index_date(solr_doc)
      end
    end

    def index_date(solr_doc)
      return if object.complex_date.blank?
      # json object as complex_date displayable
      solr_doc[Solrizer.solr_name('complex_date', :displayable)] = object.complex_date.to_json
      # date as complex_date searchable
      dates = object.complex_date.map { |d| d.date.reject(&:blank?) }.flatten
      # cope with just a year being supplied
      begin
        dates_utc = dates.map{|d| d.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')}.map { |d| d.length <= 4 ? DateTime.strptime(d, '%Y').utc.iso8601 : DateTime.parse(d).utc.iso8601 } unless dates.blank?
      rescue ArgumentError
        dates_utc = dates.map{|d| d.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')}.map { |d| DateTime.parse("#{d}-01").utc.iso8601 } unless dates.blank?
      end
      solr_doc[Solrizer.solr_name('complex_date', :stored_searchable, type: :date)] = dates_utc unless dates.blank?
      solr_doc[Solrizer.solr_name('complex_date', :dateable)] = dates_utc unless dates.blank?
      # add year
      years = dates_utc.map {|d| DateTime.parse(d).strftime("%Y")} unless dates.blank?
      solr_doc[Solrizer.solr_name('complex_year', :stored_searchable)] = years unless dates.blank?
      solr_doc[Solrizer.solr_name('complex_year', :facetable)] = years unless dates.blank?
      object.complex_date.each do |d|
        next if d.date.reject(&:blank?).blank?
        label = 'other'
        unless d.description.blank?
          # Finding its display label for indexing
          term = DateService.new.find_by_id(d.description.first)
          label = term['label'] if term.any?
        end
        label = label.downcase.tr(' ', '_')
  	    # Not indexing date as sortbale as it needs to be single valued
        # fld_name = Solrizer.solr_name("complex_date_#{label.downcase.tr(' ', '_')}", :stored_sortable, type: :date)
        # solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        # solr_doc[fld_name] << DateTime.parse(d.date.reject(&:blank?).first).utc.iso8601
        # solr_doc[fld_name] = solr_doc[fld_name].uniq.first
        # date as complex_date_type dateable
        vals = d.date.reject(&:blank?)
        fld_name = Solrizer.solr_name("complex_date_#{label}", :dateable)
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        begin
          dates_utc = vals.map{|d| d.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')}.map { |d| d.length <= 4 ? DateTime.strptime(d, '%Y').utc.iso8601 : DateTime.parse(d).utc.iso8601 } unless dates.blank?
        rescue ArgumentError
          dates_utc = vals.map{|d| d.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')}.map { |d| DateTime.parse("#{d}-01").utc.iso8601 } unless dates.blank?
        end
        solr_doc[fld_name] << dates_utc unless dates_utc.blank?
        solr_doc[fld_name].flatten!
        # Add years
        year_fld = Solrizer.solr_name("complex_year_#{label}", :facetable)
        years = dates_utc.map {|d| DateTime.parse(d).strftime("%Y")}
        solr_doc[year_fld] = [] unless solr_doc.include?(year_fld)
        solr_doc[year_fld] << years unless years.blank?
        solr_doc[year_fld].flatten!
        # date as complex_date_type displayable
        fld_name = Solrizer.solr_name("complex_date_#{label}", :displayable)
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << vals unless vals.blank?
        solr_doc[fld_name].flatten!
      end
    end

    def self.date_facet_fields
      # solr fields that will be treated as facets
      fields = []
      # change all dates to years
      fields << Solrizer.solr_name('complex_year_accepted', :facetable)
      fields << Solrizer.solr_name('complex_year_available', :facetable)
      fields << Solrizer.solr_name('complex_year_copyrighted', :facetable)
      fields << Solrizer.solr_name('complex_year_collected', :facetable)
      fields << Solrizer.solr_name('complex_year_created', :facetable)
      fields << Solrizer.solr_name('complex_year_issued', :facetable)
      fields << Solrizer.solr_name('complex_year_published', :facetable)
      fields << Solrizer.solr_name('complex_year_submitted', :facetable)
      fields << Solrizer.solr_name('complex_year_updated', :facetable)
      fields << Solrizer.solr_name('complex_year_valid', :facetable)
      fields << Solrizer.solr_name('complex_year_processed', :facetable)
      fields << Solrizer.solr_name('complex_year_purchased', :facetable)
      fields << Solrizer.solr_name('complex_year_other', :facetable)
      fields
    end

    def self.date_search_fields
      # solr fields that will be used for a search
      fields = []
      fields << Solrizer.solr_name('complex_date', :stored_searchable, type: :date)
      fields << Solrizer.solr_name('complex_year', :stored_searchable)
      fields
    end

    def self.date_show_fields
      # solr fields that will be used to display results on the record page
      fields = []
      fields << Solrizer.solr_name('complex_date_accepted', :displayable)
      fields << Solrizer.solr_name('complex_date_available', :displayable)
      fields << Solrizer.solr_name('complex_date_copyrighted', :displayable)
      fields << Solrizer.solr_name('complex_date_collected', :displayable)
      fields << Solrizer.solr_name('complex_date_created', :displayable)
      fields << Solrizer.solr_name('complex_date_issued', :displayable)
      fields << Solrizer.solr_name('complex_date_published', :displayable)
      fields << Solrizer.solr_name('complex_date_submitted', :displayable)
      fields << Solrizer.solr_name('complex_date_updated', :displayable)
      fields << Solrizer.solr_name('complex_date_valid', :displayable)
      fields << Solrizer.solr_name('complex_date_processed', :displayable)
      fields << Solrizer.solr_name('complex_date_purchased', :displayable)
      fields << Solrizer.solr_name('complex_date_other', :displayable)
      fields
    end

  end
end

