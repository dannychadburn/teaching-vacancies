module SubscriptionHelper
  def hex?(reference)
    reference.match(/^\h+$/)
  end

  def frequency_options
    Subscription::FREQUENCY_OPTIONS.map do |key, _|
      [key, I18n.t("subscriptions.frequency.#{key}")]
    end
  end
end
