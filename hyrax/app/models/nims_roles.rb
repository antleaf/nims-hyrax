module NIMSRoles
  def authenticated_nims_researcher?
    unless defined?(@authenticated_nims_researcher)
      if !guest? && employee_type_code.present? && employee_type_code =~ /^1[1-3]$/i
        @authenticated_nims_researcher = true
      else
        @authenticated_nims_researcher = false
      end
    end
    @authenticated_nims_researcher
  end

  def authenticated_nims_other?
    unless defined?(@authenticated_nims_other)
      if !guest? && employee_type_code.present? && employee_type_code =~ /^2[1-2]$/i
        @authenticated_nims_other = true
      else
        @authenticated_nims_other = false
      end
    end
    @authenticated_nims_other
  end

  def authenticated_nims?
    authenticated_nims_researcher? || authenticated_nims_other?
  end

  def authenticated_external?
    # Coming in Phase 3 (June 2020)
    external_user?
  end

  def email_user?
    return true if employee_type_code == '60'
    false
  end

  def external_user?
    return true if employee_type_code == '30'
    false
  end

  def authenticated?
    authenticated_nims? || authenticated_external?
  end
end
