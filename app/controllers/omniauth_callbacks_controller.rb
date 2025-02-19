class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :dfe

  def dfe
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id)

    if authorisation.authorised_support_user?
      sign_in_support_user
      trigger_successful_support_user_sign_in_event(:dsi)
      redirect_to after_sign_in_path_for(:support_user)
    elsif authorisation.authorised_publisher?
      sign_in_publisher(organisation_from_request)
      trigger_successful_publisher_sign_in_event(:dsi)
      redirect_to after_sign_in_path_for(:publisher)
    else
      trigger_failed_dsi_sign_in_event(:dsi, user_id)
      render "not_authorised", locals: { email: auth_hash["info"]["email"] }
    end
  end

  def failure
    report_omniauth_error
    redirect_to new_publisher_session_path, warning: t(".message")
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_id
    auth_hash["uid"]
  end

  def organisation_id
    auth_hash.dig("extra", "raw_info", "organisation", "id")
  end

  def id_token
    auth_hash.dig("credentials", "id_token")
  end

  def organisation_from_request
    # https://github.com/DFE-Digital/login.dfe.public-api#how-do-ids-map-to-categories-and-types
    case (cat_id = auth_hash.dig("extra", "raw_info", "organisation", "category", "id"))
    when "001"
      School.find_by!(urn: auth_hash.dig("extra", "raw_info", "organisation", "urn"))
    when "002"
      SchoolGroup.find_by!(local_authority_code: auth_hash.dig("extra", "raw_info", "organisation", "establishmentNumber"))
    when "010"
      SchoolGroup.find_by!(uid: auth_hash.dig("extra", "raw_info", "organisation", "uid"))
    else
      raise OrganisationCategoryNotFound, "Organisation category ID `#{cat_id}`"
    end
  end

  def sign_in_publisher(organisation)
    publisher = find_or_create(Publisher)

    OrganisationPublisher.find_or_create_by(organisation_id: organisation.id, publisher_id: publisher.id)

    sign_in(publisher)
    sign_out_except(:publisher)
    session.update(publisher_dsi_token: id_token, publisher_organisation_id: organisation.id)
    use_school_group_if_available(publisher, organisation)
  end

  def sign_in_support_user
    support_user = find_or_create(SupportUser)
    sign_in(support_user)
    sign_out_except(:support_user)
  end

  def find_or_create(klass)
    klass.find_or_create_by(oid: user_id).tap do |record|
      info = auth_hash.fetch("info")
      record.update(
        email: info["email"],
        given_name: info["first_name"],
        family_name: info["last_name"],
      )
    end
  end

  def use_school_group_if_available(publisher, organisation)
    return unless organisation.school?

    publisher_organisation = publisher.organisations.school_groups.find { |school_group| school_group.schools.include?(organisation) }
    session.update(publisher_organisation_id: publisher_organisation.id) if publisher_organisation
  end

  def not_found(error)
    # Overrides `ApplicationController`, which globally rescues all `ActiveRecord::RecordNotFound`
    # errors and shows a "page not found" error page to the user.
    # It's unexpected for a record to not be found as part of the sign in process, so send this
    # error to our error tracking system so it can be investigated.
    Sentry.with_scope do |scope|
      scope.set_context(
        "Authentication Context",
        {
          user_id: user_id,
          auth_hash_info: auth_hash["info"],
          auth_hash_extra: auth_hash["extra"],
        },
      )

      Sentry.capture_exception(error)
    end

    Rails.logger.error("Not found error encountered during sign in", error)

    super
  end

  def report_omniauth_error
    omniauth_error = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]

    # This error means DSI has redirected the user back to us after the user's session has expired
    # on _their_ end - it's an expected occurrence and not an error we want to track.
    return if omniauth_error.respond_to?(:error) && omniauth_error.error.to_s == "sessionexpired"

    Sentry.with_scope do |scope|
      scope.set_tags(
        "omniauth.error": omniauth_error,
        "omniauth.failed_strategy": failed_strategy.name,
      )

      if omniauth_error.is_a?(OmniAuth::Strategies::OpenIDConnect::CallbackError)
        scope.set_tags(
          "omniauth.error_type": omniauth_error.error,
          "omniauth.error_reason": omniauth_error.error_reason,
        )
      end

      Sentry.capture_message("User failed to sign in with DfE Sign In")
    end
  end

  class OrganisationCategoryNotFound < StandardError; end
end
