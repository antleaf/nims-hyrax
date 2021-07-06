module Metadata
  module JpcoarMapping

    def jpcoar_managing_organization(_field, xml)
      return if managing_organization.blank? or managing_organization[0].blank?
      # jpcoar:contributor@contributorType="HostingInstitution"/jpcoar:affiliation/jpcoar:affiliationName
      # language attribute: TRUE
      # Note: Only mapping the first value
      # if self.has? "managing_organization_tesim" and self["managing_organization_tesim"].present?
      val = managing_organization.first
      xml.tag!('jpcoar:contributor', "contributorType" => "HostingInstitution") do
        xml.tag!("jpcoar:affiliation") do
          xml.tag!('jpcoar:affiliationName', val, "xml:lang" => "en")
        end
      end
    end

    def jpcoar_first_published_url(_field, xml)
      return if first_published_url.blank? or first_published_url[0].blank?
      # jpcoar:relation@relationType="isVersionOf"/jpcoar:relatedIdentifier@identifierType="DOI"
      # language attribute: FALSE
      # Note: Only mapping the first value
      val = first_published_url.first
      xml.tag!('jpcoar:relation', "relationType" => "isVersionOf") do
        xml.tag!('jpcoar:relatedIdentifier', val, "identifierType" => "DOI")
      end
    end

    def jpcoar_title(_field, xml)
      return if title.blank? or title[0].blank?
      # dc:title
      # language attribute: TRUE
      # Note: Only mapping the first value
      val = title.first
      xml.tag!('dc:title', val, "xml:lang" => "en")
    end

    def jpcoar_alternative_title(_field, xml)
      return if alternative_title.blank?
      # Alternative title		dcterms:alternative
      # language attribute: TRUE
      alternative_title.each do |val|
        xml.tag!('dc:alternative', val, "xml:lang" => "en") unless val.blank?
      end
    end

    def jpcoar_resource_type(_field, xml)
      return if resource_type.blank?
      # dc:type@rdf:resource="COAR Resource Type URI" See Resource Type sheet
      # language attribute: FALSE
      # Note: If the mapping is not defined, it will not be included
      resource_type_map = {
        'Article' => 'http://purl.org/coar/resource_type/c_6501',
        'Audio' => 'http://purl.org/coar/resource_type/c_18cc',
        'Book' => 'http://purl.org/coar/resource_type/c_2f33',
        'Conference Proceeding' => 'http://purl.org/coar/resource_type/c_f744',
        'Dataset' => 'http://purl.org/coar/resource_type/c_ddb1',
        'Dissertation' => 'http://purl.org/coar/resource_type/c_46ec',
        'Image' => 'http://purl.org/coar/resource_type/c_c513',
        'Journal' => 'http://purl.org/coar/resource_type/c_2659',
        'Part of Book' => 'http://purl.org/coar/resource_type/c_3248',
        'Poster' => 'http://purl.org/coar/resource_type/c_6670',
        'Presentation' => 'http://purl.org/coar/resource_type/c_c94f',
        'Report' => 'http://purl.org/coar/resource_type/c_93fc',
        'Software or Program Code' => 'http://purl.org/coar/resource_type/c_5ce6',
        'Video' => 'http://purl.org/coar/resource_type/c_12ce',
        'Other' => 'http://purl.org/coar/resource_type/c_1843',
      }
      resource_type.each do |val|
        next if val.blank?
        next unless resource_type_map.include?(val)
        xml.tag!('dc:type', val, "rdf:resource" => resource_type_map[val])
      end
    end

    def jpcoar_description(_field, xml)
      return if description.blank?
      # datacite:description@descriptionType="Abstract"
      # language attribute: TRUE
      description.each do |val|
        xml.tag!('datacite:description', val, "descriptionType" => "Abstract", "xml:lang" => "en") unless val.blank?
      end
    end

    def jpcoar_keyword(_field, xml)
      return if keyword.blank?
      # jpcoar:subject@subjectScheme="Other"
      # language attribute: TRUE
      keyword.each do |val|
        xml.tag!('jpcoar:subject', val, "subjectScheme" => "Other", "xml:lang" => "en") unless val.blank?
      end
    end

    def jpcoar_publisher(_field, xml)
      return if publisher.blank?
      # dc:publisher
      # language attribute: TRUE
      publisher.each do |val|
        xml.tag!('dc:publisher', val, "xml:lang" => "en") unless val.blank?
      end
    end

    def jpcoar_date_published(_field, xml)
      return if date_published.blank? or date_published[0].blank?
      # datacite:date@dateType="Issued"
      # language attribute: FALSE
      # Note: Only mapping the first value
      val = date_published.first
      xml.tag!('datacite:date', val, "dateType" => "Issued")
    end

    def jpcoar_rights_statement(_field, xml)
      return if rights_statement.blank?
      # dc:rights@rdf:resource="URI"
      # language attribute: TRUE
      rights_statement.each do |val|
        next if val.blank?
        term = RightsStatementService.new.find_by_id(val)
        label = term.any? ? term['label'] : val
        xml.tag!('dc:rights', label, "rdf:resource" => val, "xml:lang" => "en")
      end
    end

    def jpcoar_complex_person(_field, xml)
      return if complex_person.blank? or complex_person[0].blank?
      role_map = {
        'author' => 'creator',
        'editor' => 'Editor',
        'translator' => 'Other',
        'data depositor' => 'Other',
        'data curator' =>	'DataCurator',
        'contact person' => 'ContactPerson',
        'operator' =>	'Other'
      }
      if complex_person.present?
        people = JSON.parse(complex_person[0])
        people.each do |person|
          # Get the role and map it
          role = person.dig('role').present? ? person['role'].first : 'Other'
          role = 'Other' if role.blank?
          role = role_map.include?(role) ? role_map[role] : 'Other'
          # Assign parent tag
            # use jpcoar:creator for creator
            # use jpcoar:contributor@contributorType="[(JPCOAR vocabulary)]" for other than creator
          parent_tag_name = role == 'creator' ? 'jpcoar:creator' : 'jpcoar:contributor'
          if role == 'creator'
            xml.tag!(parent_tag_name) do
              add_person_attributes(person, xml, parent_tag_name)
            end
          else
            xml.tag!(parent_tag_name, 'contributorType' => role ) do
              add_person_attributes(person, xml, parent_tag_name)
            end
          end
        end
      end
    end

    def add_person_attributes(person, xml, parent_tag_name)
      # last_name
        # jpcoar:familyName
        # language attribute: TRUE
      v = person.dig('last_name').present? ? person['last_name'].first : nil
      xml.tag!('jpcoar:familyName', v, "xml:lang" => "en") unless v.blank?
      # first_name
        # jpcoar:givenName
        # language attribute: TRUE
      v = person.dig('first_name').present? ? person['first_name'].first : nil
      xml.tag!('jpcoar:givenName', v, "xml:lang" => "en") unless v.blank?
      # name
        # jpcoar:creatorName / jpcoar:contributorName
        # language attribute: TRUE
      v = person.dig('name').present? ? person['name'].first: nil
      xml.tag!(parent_tag_name + 'Name', v, "xml:lang" => "en") unless v.blank?
      # orcid
        # jpcoar:nameIdentifier@nameIdentifierScheme="ORCID" nameIdentifierURI="[HTTP URI]"
        # language attribute: FALSE
      v = person.dig('orcid').present? ? person['orcid'].first: nil
      doi = v.delete_prefix("https://orcid.org/").delete_suffix('/') unless v.blank?
      xml.tag!('jpcoar:nameIdentifier', doi, "nameIdentifierScheme" => "ORCID", 'nameIdentifierURI' => v) unless v.blank?
      # organization
        # jpcoar:affiliation/jpcoar:affiliationName
        # language attribute: TRUE
      v = person.dig('organization').present? ? person['organization'].first : nil
      xml.tag!('jpcoar:affiliation') do
        xml.tag!('jpcoar:affiliationName', v, "xml:lang" => "en") unless v.blank?
      end
    end

    def jpcoar_complex_source(_field, xml)
      return if complex_source.blank? or complex_source[0].blank?
      sources = JSON.parse(complex_source[0])
      sources.each do |source|
        # Title		jpcoar:sourceTitle	TRUE
        v = source.dig('title').present? ? source['title'].first : nil
        xml.tag!('jpcoar:sourceTitle', v, "xml:lang" => "en") unless v.blank?
        # Issn		jpcoar:sourceIdentifier@identifierType="ISSN"	FALSE
        v = source.dig('issn').present? ? source['issn'].first : nil
        xml.tag!('jpcoar:sourceIdentifier', v, "identifierType" => "ISSN") unless v.blank?
        # Volume		jpcoar:volume	FALSE
        v = source.dig('volume').present? ? source['volume'].first : nil
        xml.tag!('jpcoar:volume', v) unless v.blank?
        # Issue		jpcoar:issue	FALSE
        v = source.dig('issue').present? ? source['issue'].first : nil
        xml.tag!('jpcoar:issue', v) unless v.blank?
        # Start page		jpcoar:pageStart	FALSE
        v = source.dig('start_page').present? ? source['start_page'].first : nil
        xml.tag!('jpcoar:pageStart', v) unless v.blank?
        # End page		jpcoar:pageEnd	FALSE
        v = source.dig('end_page').present? ? source['end_page'].first : nil
        xml.tag!('jpcoar:pageEnd', v) unless v.blank?
        # Total number of pages		jpcoar:numPages	FALSE
        v = source.dig('total_number_of_pages').present? ? source['total_number_of_pages'].first : nil
        xml.tag!('jpcoar:numPages', v) unless v.blank?
      end
    end

    def jpcoar_manuscript_type(_field, xml)
      return if manuscript_type.blank?
      # oaire:version@rdf:resource="[COAR Resource Type URI]” See Manuscipt type sheet	FALSE
      manuscript_type_map = {
        'Original' => {'uri' => 'http://purl.org/coar/version/c_b1a7d7d4d402bcce', 'label' => 'AO'},
        'Accepted' => {'uri' => 'http://purl.org/coar/version/c_ab4af688f83e57aa', 'label' => 'AM' },
        'Proof' => {'uri' => 'http://purl.org/coar/version/c_fa2ee174bc00049f', 'label' => 'P' },
        'Version' => {'uri' => 'http://purl.org/coar/version/c_970fb48d4fbd8a85', 'label' => 'VoR' },
        'other' => {'uri' => 'http://purl.org/coar/version/c_be7fb7dd8ff6fe43', 'label' => 'NA'},
      }
      manuscript_type.each do |val|
        next if val.blank?
        mapped_val = manuscript_type_map.include?(val) ? manuscript_type_map[val] : manuscript_type_map['other']
        xml.tag!('oaire:version', mapped_val['label'], "rdf:resource" => mapped_val['uri'])
      end
    end

    def jpcoar_complex_event(_field, xml)
      return if complex_event.blank? or complex_event[0].blank?
      events = JSON.parse(complex_event[0])
      events.each do |event|
        xml.tag!('jpcoar:conference') do
          # Title		jpcoar:conferenceName	TRUE
          v = event.dig('title').present? ? event['title'].first : nil
          xml.tag!('jpcoar:conferenceName', v, "xml:lang" => "en") unless v.blank?
          # Place		jpcoar:conferencePlace	TRUE
          v = event.dig('place').present? ? event['place'].first : nil
          xml.tag!('jpcoar:conferencePlace', v, "xml:lang" => "en") unless v.blank?
          # conference date
          # <jpcoar:conferenceDate xml:lang="en" startDay="29" startMonth="02" startYear="2016"
          # endDay="04" endMonth="03" endYear="2016">February 29th to March 4th, 2016</jpcoar:conferenceDate>
          date_attribute_hash = {"xml:lang" => "en"}
          conf_date = []
          v_start = event.dig('start_date').present? ? event['start_date'].first : nil
          if v_start.present?
            conf_date << v_start
            begin
              start_date = Date.parse(v_start)
            rescue
              start_date = nil
            end
            if start_date.present?
              date_attribute_hash['startDay'] = start_date.day
              date_attribute_hash['startMonth'] = start_date.month
              date_attribute_hash['startYear'] = start_date.year
            end

          end
          v_end = event.dig('end_date').present? ? event['end_date'].first : nil
          if v_end.present?
            conf_date << v_end
            begin
              end_date = Date.parse(v_end)
            rescue
              end_date = nil
            end
            if end_date.present?
              date_attribute_hash['endDay'] = end_date.day
              date_attribute_hash['endMonth'] = end_date.month
              date_attribute_hash['endYear'] = end_date.year
            end
          end
          xml.tag!('jpcoar:conferenceDate', conf_date.join(' to '), date_attribute_hash) unless conf_date.blank?
        end

      end
    end

    def jpcoar_complex_date(_field, xml)
      return if complex_date.blank? or complex_date[0].blank?
      # datacite:date@dateType="[(JPCOAR vocabulary)]" See Other date sheet
      # language attribute: FALSE
      complex_date_map = {
        'http://purl.org/dc/terms/dateAccepted' => 'Accepted',
        'Available' => 'Available',
        'http://bibframe.org/vocab/copyrightDate' => 'Copyrighted',
        'Collected' => 'Collected',
        'http://purl.org/dc/terms/created' => 'Created',
        'http://bibframe.org/vocab/providerDate' => 'Submitted',
        'http://bibframe.org/vocab/changeDate' => 'Updated',
      }

      dates = JSON.parse(complex_date[0])
      dates.each do |date_val|
        label = nil
        if date_val.dig('description').present? and date_val['description'][0].present? and complex_date_map.include?(date_val['description'][0])
          label = complex_date_map[date_val['description'][0]]
        end
        val = nil
        if date_val.dig('date').present? and date_val['date'][0].present?
          val = date_val['date'][0]
        end
        if label.present? and val.present?
          xml.tag!('datacite:date', val, 'dateType' => label)
        end
      end
    end

    def jpcoar_complex_identifier(_field, xml)
      return if complex_identifier.blank? or complex_identifier[0].blank?
      # jpcoar:identifier@identifierType="DOI"
      complex_id_map = {
        'DOI' => 'DOI'
      }
      identifiers = JSON.parse(complex_identifier[0])
      identifiers.each do |identifier|
        label = nil
        if identifier.dig('scheme').present? and identifier['scheme'][0].present? and complex_id_map.include?(identifier['scheme'][0])
          label = complex_id_map[identifier['scheme'][0]]
        end
        val = nil
        if identifier.dig('identifier').present? and identifier['identifier'][0].present?
          val = identifier['identifier'][0]
        end
        if label.present? and val.present?
          xml.tag!('jpcoar:identifier', val, 'identifierType' => label)
        end
      end
    end

    def jpcoar_complex_version(_field, xml)
      return if complex_version.blank? or complex_version[0].blank?
      # datacite:version
      versions = JSON.parse(complex_version[0])
      versions.each do |version|
        val = nil
        if version.dig('version').present? and version['version'][0].present?
          val = version['version'][0]
        end
        xml.tag!('datacite:version', val) unless val.blank?
      end
    end

    def jpcoar_complex_relation(_field, xml)
      return if complex_relation.blank? or complex_relation[0].blank?
      complex_relation_map = {
        'isNewVersionOf' => 'isVersionOf',
        'isPreviousVersionOf' => 'hasVersion',
        'isSupplementTo' => 'isSupplementTo',
        'isSupplementedBy' => 'isSupplementedBy',
        'isPartOf' => 'isPartOf',
        'hasPart' => 'hasPart',
        'isReferencedBy' => 'isReferencedBy',
        'references' => 'references',
        'isIdenticalTo' => 'isIdenticalTo',
        'isDerivedFrom' => 'isDerivedFrom',
        'isSourceOf' => 'isSourceOf',
        'requires' => 'requires',
        'isRequiredBy' => 'isRequiredBy',
      }
      relations = JSON.parse(complex_relation[0])
      relations.each do |relation|
        relation_type = nil
        if relation.dig('relationship').present? and relation['relationship'][0].present? and complex_relation_map.include?(relation['relationship'][0])
          relation_type = complex_relation_map[relation['relationship'][0]]
        end
        title = nil
        if relation.dig('title').present? and relation['title'][0].present?
          title = relation['title'][0]
        end
        url = nil
        if relation.dig('url').present? and relation['url'][0].present?
          url = relation['url'][0]
        end
        if relation_type.present? and (title.present? or url.present?)
          # jpcoar:relation @relationType="[(JPCOAR vocabulary)]" See Relationship sheet	FALSE
          xml.tag!('jpcoar:relation', 'relationType' => relation_type) do
            # Title	jpcoar:relatedTitle	TRUE
            xml.tag!('jpcoar:relatedTitle', title, 'xml:lang' => 'en') unless title.blank?
            # Url	jpcoar:relatedIdentifier@identifierType="URI"	FALSE
            xml.tag!('jpcoar:relatedIdentifier', url, 'identifierType' => 'URI') unless url.blank?
          end
        end
      end
    end
  end
end