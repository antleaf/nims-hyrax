# frozen_string_literal: true

class AddIdentifierService
  attr_reader :dataset, :person, :user

  def initialize(dataset_id: , user_id: , complex_person_id: nil, complex_person_name: nil)
    raise StandardError 'complex_person_id or complex_person_name must be specified' if complex_person_id.nil? && complex_person_name.nil?

    @dataset = Dataset.find(dataset_id)
    if complex_person_id.present?
      @person = dataset.complex_person.select { |p| p.id == complex_person_id }.first
    elsif complex_person_name.present?
      @person = dataset.complex_person.select { |p| p.name.include?(complex_person_name) }.first
    end
    raise StandardError 'complex_person could not be found' if person.nil?

    @user = User.find(user_id)
  end

  def add_identifier(identifier_type:, identifier_value:)
    raise StandardError 'invalid identifier_type' unless valid_type?(identifier_type)

    valid_type?
    attr = clean_attributes

    attr[:complex_person_attributes][0][:complex_identifier_attributes] = [
      complex_identifier_attributes(identifier_type, identifier_value)
    ]

    env = Hyrax::Actors::Environment.new(dataset, user.ability, attr)
    Hyrax::CurationConcern.actor.update(env)
    dataset.reload
  end

  def clean_attributes
    attributes.delete('complex_identifier')
    attributes.delete('complex_affiliation')
    { complex_person_attributes: [attributes] }
  end

  def attributes
    @attributes ||= person.attributes
  end

  def complex_identifier_attributes(identifier_type, identifier_value)
    {
      identifier: [identifier_value],
      scheme: [identifier_type]
    }
  end

  # def deleted_complex_identifier_attributes(identifier_type)
  #   existing_identifier = person.complex_identifier.select { |i| i.scheme == [identifier_type] }.first
  #   return {} if existing_identifier.blank?
  #   {
  #     id: existing_identifier.id,
  #     '_destroy' => '1'
  #   }
  # end

  def valid_type?(identifier_type)
    true if IdentifierService.new.select_active_options.map(&:last).include?(identifier_type)
  end
end
