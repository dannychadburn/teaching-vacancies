class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [UnitedLearningVacancySource].freeze

  queue_as :default

  def perform
    SOURCES.each do |source_klass|
      source_klass.new.each do |vacancy|
        # TODO: Basic validation would happen here
        if vacancy.save
          Rails.logger.info("Imported vacancy #{vacancy.id} from feed #{source_klass.name}")
        else
          Rails.logger.error("Failed to save imported vacancy: #{vacancy.errors.inspect}")
        end
      end
    end
  end
end
