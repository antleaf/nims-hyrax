FactoryBot.define do

  factory :publication do
    title { ["Publication"] }
    access_control

    trait :open do
      visibility { 'open' }
      title { ["Open Publication"] }
    end

    trait :authenticated do
      visibility { 'authenticated' }
      title { ["Authenticated Publication"] }
    end

    trait :restricted do
      visibility { 'restricted' }
      title { ["Restricted Publication"] }
    end

    trait :with_complex_author do
      complex_person_attributes {
        [{
          name: ['Foo Bar'],
          role: ['author'],
          orcid: ['https://orcid.example.org/0000-1111-2222-3333'],
          organization: ['National Institute for Materials Science'],
          sub_organization: ['MaDIS DPFC'],
          complex_identifier_attributes: [{
            identifier: '123456',
            scheme: 'identifier local'
          }],
          complex_affiliation_attributes: [{
            job_title: 'Principal Investigator',
            complex_organization_attributes: [{
              organization: 'University',
              sub_organization: 'Department',
              purpose: 'Research'
            }]
          }
        ]}, {
          name: ['Big Buz'],
          role: ['editor'],
        }, {
          name: ['Small Buz'],
          role: ['author'],
        }, {
          first_name: ['Moo'],
          last_name: ['Milk'],
          name: ['Moo Milk'],
          role: ['data depositor']
        }]
      }
    end

    trait :with_alternative_title do
      alternative_title { 'Alternative-Title-123' }
    end

    trait :with_keyword do
      keyword { ['Keyword-123'] }
    end

    trait :with_subject do
      subject { ['Subject-123'] }
    end

    trait :with_language do
      language { ['Faroese'] }
    end

    trait :with_resource_type do
      resource_type { ['Resource-Type-123'] }
    end

    trait :with_source do
      source { ['Source-123'] }
    end

    trait :with_rights_statement do
      rights_statement { ['Rights-Statement-123'] }
    end

    trait :with_issue do
      issue { 'Issue-123' }
    end

    trait :with_table_of_contents do
      table_of_contents { 'Table-of-Contents-123' }
    end

    trait :with_number_of_pages do
      total_number_of_pages { 'Number-of-Pages-123' }
    end

    trait :with_complex_identifier do
      complex_identifier_attributes {
        [
          { identifier: '10.0.1111', scheme: 'http://dx.doi.org', label: 'DOI' },
          { identifier: '10.0.2222', scheme: 'HTTPS://DX.DOI.ORG', label: 'DOI' },
          { identifier: '3333', label: 'Local ID' }
        ]
      }
    end

    trait :with_solr_document do
      solr_document { {} }
    end

    trait :with_complex_date do
      complex_date_attributes { [{ date: '2019-05-28',  description: 'Published' }] }
    end

    trait :with_place do
      place { '221B Baker Street Place' }
    end

    trait :with_publisher do
      publisher { ['Publisher-123'] }
    end

    trait :with_complex_event do
      complex_event_attributes {
        [{
             title: 'Event-Title-123',
             invitation_status: true,
             place: 'New Scotland Yard',
             start_date: '2018-12-25',
             end_date: '2019-01-01'
        }]
      }
    end

    trait :with_complex_source do
      complex_source_attributes {
        [{
          alternative_title: 'Sub title for journal',
          complex_person_attributes: [{
            name: 'AR',
            role: 'Editor'
          }],
          end_page: '12',
          complex_identifier_attributes: [{
            identifier: '1234567',
            scheme: 'Local'
          }],
          issue: '34',
          sequence_number: '1.2.2',
          start_page: '4',
          title: 'Test journal',
          total_number_of_pages: '8',
          volume: '3'
        }]
      }
    end

    trait :with_complex_rights do
      complex_rights_attributes {
        [{
           date: '1980-10-10',
           rights: 'http://creativecommons.org/publicdomain/zero/1.0/'
         }]
      }
    end

    trait :with_complex_version do
      complex_version_attributes {
        [{
           date: '1990-12-12',
           description: 'Creating the first version',
           identifier: 'id1',
           version: '1.0'
         }]
      }
    end

    trait :with_description_abstract do
      description { ["Abstract-Description-123"] }
    end

    trait :with_supervisor_approval do
      supervisor_approval { ['Professor-Supervisor-Approval'] }
    end
  end
end
