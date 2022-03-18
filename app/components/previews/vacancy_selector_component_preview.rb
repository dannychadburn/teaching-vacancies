class VacancySelectorComponentPreview < Base
  def self.options
    @options ||= Organisation.first
  end

  def self.component_class
    VacancySelectorComponent
  end
end
