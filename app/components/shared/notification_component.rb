class Shared::NotificationComponent < GovukComponent::Base
  attr_accessor :variant, :links, :title, :body, :dismiss, :background, :icon

  # rubocop:disable Metrics/ParameterLists
  def initialize(variant: "success",
                 links: nil,
                 title: "",
                 body: "",
                 dismiss: true,
                 background: false,
                 icon: false,
                 classes: [],
                 html_attributes: {})

    @body = body
    @title = title
    @variant = variant
    @links = links
    @dismiss = variant == "warning" ? false : dismiss
    @background = background
    @icon = %w[warning success].include?(variant) ? true : icon

    super(classes: classes, html_attributes: html_attributes.merge(default_html_attributes))
  end
  # rubocop:enable Metrics/ParameterLists

  def variant_class
    "govuk-notification--#{@variant}"
  end

  def background_class
    "govuk-notification__background"
  end

  def icon_class
    "icon icon--left icon--#{@variant}"
  end

  def dismissable_class
    "js-dismissible"
  end

  def default_html_attributes
    if @variant == "empty"
      {}
    else
      { role: "alert", tabindex: "-1" }
    end
  end

  private

  def default_classes
    ["notification-component", "govuk-notification", variant_class].tap do |applied_classes|
      applied_classes.push(background_class) if @background
      applied_classes.push(icon_class) if @icon
      applied_classes.push(dismissable_class) if @dismiss
    end
  end
end
