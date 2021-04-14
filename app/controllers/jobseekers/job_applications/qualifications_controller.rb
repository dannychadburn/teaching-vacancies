class Jobseekers::JobApplications::QualificationsController < Jobseekers::BaseController
  helper_method :back_path, :category, :form, :job_application, :qualification,
                :submit_text

  include QualificationConcerns

  def submit_category
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
      redirect_to new_jobseekers_job_application_qualification_path(qualification_params)
    else
      render :select_category
    end
  end

  def create
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
      job_application.qualifications.create(qualification_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
      qualification.update(qualification_params)
      redirect_to back_path
    else
      render :edit
    end
  end


  def destroy
    count = qualifications.count
    qualifications.each(&:destroy)
    redirect_to back_path, success: t(".success", count: count)
  end

  private

  def form
    @form ||= form_class(category).new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      { category: category }
    when "select_category"
      {}
    when "edit"
      qualification.slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year)
    when "create", "update", "submit_category"
      qualification_params
    end
  end

  def qualification_params
    case action_name
    when "new", "select_category", "submit_category"
      (params[form_param_key(category)] || params).permit(:category)
    when "create", "edit", "update"
      params.require(form_param_key(category))
            .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year)
    end
  end

  def category
    @category ||= action_name.in?(%w[edit update]) ? qualification.category : category_param
  end

  def category_param
    params.permit(:category)[:category]
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :qualifications)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def qualification
    @qualification ||= job_application.qualifications.find(params[:id])
  end

  def qualifications
    @qualifications ||= [job_application.qualifications.find(params[:ids])].flatten
  end

  def submit_text
    category.in?(%w[undergraduate postgraduate other]) ? t("buttons.save_qualification.one") : t("buttons.save_qualification.other")
  end
end
