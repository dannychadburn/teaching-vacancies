class SearchableCollectionComponentPreview < ViewComponent::Preview
  layout "application"

  OPTIONS = [["Accounting", "includes Finance and accounting"]]

  def self.component_name
    component_class.to_s.underscore.humanize.split.first.downcase
  end

  def self.component_class
    SearchableCollectionComponent
  end

  def self.form
    SearchableCollectionComponentPreview::Form
  end

  def preview; end
end
