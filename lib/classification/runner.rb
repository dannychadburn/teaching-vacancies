class Runner
  attr_reader :examples, :actual, :prediction, :identifier

  def initialize(examples, actual:, prediction:, identifier:)
    @examples = examples
    @actual = actual
    @prediction = prediction
    @identifier = identifier
  end

  def call
    examples.each do |example|
      id = identifier.call(example)
      actual_value = actual.call(example)
      predicted_value = prediction.call(example)

      if actual_value == predicted_value
        puts "✅ #{id} (#{predicted_value})"
      else
        puts "🛑 #{id} (#{predicted_value})"
        puts "  -> expected #{actual_value}"
      end
    end
  end
end
