class Ability
  include Hydra::Ability
  include Hyrax::Ability # NB: not the same as the line above!

  # Registered user can only create datasets and publications
  # Only admin can view the user list
  self.ability_logic += [
    :read_metadata,
    :create_content,
    :only_admin_can_view_user_list
  ]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
      # Admin user can create works of all work types
      can :create, curation_concerns_models
    end
    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end

  def create_content
    # only NIMS Researchers may upload new content
    can :create, [::Dataset, ::Publication] if current_user.authenticated_nims_researcher?
    can :create, [::Dataset, ::Publication] if current_user.authenticated_external?
    can :create, [::Dataset, ::Publication, ::Image] if current_user.admin?
  end

  def read_metadata
    can :read_abstract, [::Dataset, ::Image, ::Publication]
    can :read_alternative_title, [::Dataset, ::Image, ::Publication]
    # NB: no users can :read_application_number
    # NB: no users can :read_supervisor_approval (though it is visible on the edit form to users with permission to edit)
    cannot :read_supervisor_approval, [::Dataset, ::Image, ::Publication]
    can :read_creator, [::Dataset, ::Image, ::Publication]
    can :read_date, [::Dataset, ::Image, ::Publication]
    can :read_event, [::Publication]
    can :read_identifier, [::Dataset, ::Image, ::Publication]
    can :read_issue, [::Publication]
    can :read_table_of_contents, [::Publication]
    can :read_keyword, [::Dataset, ::Image, ::Publication]
    can :read_language, [::Dataset, ::Image, ::Publication]
    can :read_location, [::Publication]
    can :read_number_of_pages, [::Publication]
    can :read_organization, [::Dataset, ::Publication]
    can :read_publisher, [::Dataset, ::Image, ::Publication]
    can :read_related, [::Dataset, ::Publication]
    can :read_resource_type, [::Dataset, ::Image, ::Publication] #NB: added Dataset to list
    can :read_rights, [::Dataset, ::Image, ::Publication]
    can :read_source, [::Dataset, ::Publication] #NB: added Dataset to the list
    can :read_subject, [::Dataset, ::Publication, ::Image]  # NB: added Image to list
    can :read_title, [::Dataset, ::Image, ::Publication]    # NB: not used in Publication
    can :read_version, [::Dataset, ::Image, ::Publication]
  end

  def only_admin_can_view_user_list
    if current_user.admin?
      can :index, ::User
    else
      cannot :index, ::User
    end
  end

  def user_groups
    return @user_groups if @user_groups

    @user_groups = default_user_groups
    @user_groups |= current_user.groups if current_user.respond_to? :groups
    unless current_user.new_record?
      @user_groups |= ['registered'] unless current_user.email_user?
    end
    @user_group
  end
end
