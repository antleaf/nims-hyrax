# -*- encoding : utf-8 -*-
require 'builder'

module Hyrax
  module SolrDocument
    module Jpcoar
      include ::Metadata::ProcessMapping
      include ::Metadata::JpcoarMapping
      def export_as_jpcoar_xml
        xml = Builder::XmlMarkup.new
        # format = FORMAT_JPCOAR

        xml.tag!(FORMAT_JPCOAR[:'tag'][:'name'], FORMAT_JPCOAR[:'tag'][:'attributes']) do
          FORMAT_JPCOAR[:'fields'].each do |field, mapping|
            process_mapping(xml, field, mapping)
          end
        end
        xml.target!
      end

      def to_jpcoar
        export_as("jpcoar_xml")
      end

      FORMAT_JPCOAR = {
        'tag': {
          'name': 'jpcoar:jpcoar',
          'attributes': {
            'xmlns:jpcoar' => "https://github.com/JPCOAR/schema/blob/master/1.0/",
            'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
            'xmlns:dcterms' => "http://purl.org/dc/terms/",
            'xmlns:rioxxterms' => "http://www.rioxx.net/schema/v2.0/rioxxterms/",
            'xmlns:datacite' => "https://schema.datacite.org/meta/kernel-4/",
            'xmlns:oaire' => "http://namespace.openaire.eu/schema/oaire/",
            'xmlns:dcndl' => "http://ndl.go.jp/dcndl/terms/",
            'xmlns:rdf' => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation' => "https://github.com/JPCOAR/schema/blob/master/1.0/jpcoar_scm.xsd"
          }
        },
        'fields': {
          'managing_organization': {'function': 'jpcoar_managing_organization'},
          'first_published_url': {'function': 'jpcoar_first_published_url'},
          'title': {'function': 'jpcoar_title'},
          'alternative_title': {'function': 'jpcoar_alternative_title'},
          'resource_type': {'function': 'jpcoar_resource_type'},
          'description': {'function': 'jpcoar_description'},
          'keyword': {'function': 'jpcoar_keyword'},
          'publisher': {function: 'jpcoar_publisher'},
          'date_published': {function: 'jpcoar_date_published'},
          'rights_statement': {function: 'jpcoar_rights_statement'},
          'complex_person': {function: 'jpcoar_complex_person'},
          'complex_source': {function: 'jpcoar_complex_source'},
          'manuscript_type': {function: 'jpcoar_manuscript_type'},
          'complex_event': {function: 'jpcoar_complex_event'},
          'dc:language': 'language_tesim',
          'complex_date': {function: 'jpcoar_complex_date'},
          'complex_identifier': {function: 'jpcoar_complex_identifier'},
          'complex_version': {function: 'jpcoar_complex_version'},
          'complex_relation': {function: 'jpcoar_complex_relation'},
        }
      }
    end
  end
end