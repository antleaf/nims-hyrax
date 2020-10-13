require "./lib/vocabularies/nims_rdp"
class Dataset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DatasetIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your dataset must have a title.' }

  # property date_modified - defined in core metadata
  # property date_uploaded - defined in core metadata
  # property depositor - defined in core metadata
  # property title - defined in core metadata
  # property based_near - defined in the basic metadata
  # property bibliographic_citation - defined in the basic metadata
  # property contributor - defined in the basic metadata
  # property creator - defined in the basic metadata
  # property date_created - defined in the basic metadata
  # property description - defined in the basic metadata
  # property identifier - defined in the basic metadata
  # property import_url - defined in the basic metadata
  # property keyword - defined in the basic metadata
  # property label - defined in the basic metadata
  # property language - defined in the basic metadata
  # property publisher - defined in the basic metadata
  # property related_url - defined in the basic metadata
  # property relative_path - defined in the basic metadata
  # property resource_type - defined in the basic metadata
  # property license (rights) - defined in the basic metadata
  # property rights_statement - defined in the basic metadata
  # property source - defined in the basic metadata
  # property subject - defined in the basic metadata

  # Required due to bug saving nested resources
  property :updated_subresources, predicate: ::RDF::URI.new('http://example.com/updatedSubresources'), class_name: "ActiveTriples::Resource"

  property :alternative_title, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
    index.as :stored_searchable
  end

  property :complex_date, predicate: ::RDF::Vocab::DC.date, class_name:"ComplexDate"

  property :complex_identifier, predicate: ::RDF::Vocab::NimsRdp.identifier, class_name:"ComplexIdentifier"

  property :complex_person, predicate: ::RDF::Vocab::SIOC.has_creator, class_name:"ComplexPerson"

  property :complex_rights, predicate: ::RDF::Vocab::DC11.rights, class_name:"ComplexRights"

  property :complex_version, predicate: ::RDF::Vocab::NimsRdp.version, class_name:"ComplexVersion"

  property :complex_organization, predicate: ::RDF::Vocab::ORG.organization, class_name:"ComplexOrganization"

  property :characterization_methods, predicate: ::RDF::Vocab::NimsRdp['characterization-methods'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :computational_methods, predicate: ::RDF::Vocab::NimsRdp['computational-methods'] do |index|
    index.as :stored_searchable, :facetable
  end

  # TODO - This is required
  property :data_origin, predicate: ::RDF::Vocab::NimsRdp['data-origin'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :complex_instrument, predicate: ::RDF::Vocab::NimsRdp.instrument, class_name: "ComplexInstrument"

  property :origin_system_provenance, predicate: ::RDF::Vocab::NimsRdp['origin-system-provenance'], multiple: false do |index|
    index.as :stored_searchable
  end

  # NOTE: Not a part of Hyrax basic metadata
  # Not defining this field. It raises RSolr::Error::ConnectionRefused when added to index.
  # property :part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
  #   index.as :stored_searchable
  # end

  property :properties_addressed, predicate: ::RDF::Vocab::NimsRdp['properties-addressed'] do |index|
    index.as :stored_searchable, :facetable
  end

  # Defined complex_relation in common_complex_properties in place of relation
  #   This could be used to describe relationships by giving more context to the relation
  #   could be used in place of part_of and related_url
  property :complex_relation, predicate: ::RDF::Vocab::DC.relation, class_name:"ComplexRelation"

  # TODO - This is required
  property :specimen_set, predicate: ::RDF::Vocab::NimsRdp['specimen-set'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :complex_specimen_type, predicate: ::RDF::Vocab::NimsRdp['specimen-type'],
  class_name: "ComplexSpecimenType"

  property :synthesis_and_processing, predicate: ::RDF::Vocab::NimsRdp['synthesis-and-processing'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :custom_property, predicate: ::RDF::Vocab::NimsRdp['custom-property'], class_name:"ComplexKeyValue"

  property :supervisor_approval, predicate: ::RDF::Vocab::NimsRdp['supervisor-approval']

  property :first_published_url, predicate: ::RDF::Vocab::NimsRdp['first_published_url'], multiple: false do |index|
    index.as :stored_searchable
  end

  property :doi, predicate: ::RDF::Vocab::Identifiers.doi, multiple: false do |index|
    index.as :stored_searchable
  end

  property :licensed_date, predicate: ::RDF::Vocab::NimsRdp['licenced-date'], multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
  include ComplexValidation
  accepts_nested_attributes_for :complex_date, reject_if: :date_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_identifier, reject_if: :identifier_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_instrument, reject_if: :instrument_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_organization, reject_if: :organization_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_person, reject_if: :person_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_relation, reject_if: :relation_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_rights, reject_if: :rights_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_specimen_type, reject_if: :specimen_type_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_version, reject_if: :version_blank, allow_destroy: true
  accepts_nested_attributes_for :custom_property, reject_if: :key_value_blank, allow_destroy: true
  accepts_nested_attributes_for :updated_subresources, allow_destroy: true
end
