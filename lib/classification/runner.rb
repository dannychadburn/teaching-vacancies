class Runner
  attr_reader :examples, :actual, :prediction, :identifier, :fix

  def initialize(examples, actual:, prediction:, identifier:, fix: nil)
    @examples = examples
    @actual = actual
    @prediction = prediction
    @identifier = identifier
    @fix = fix
  end

  def call # rubocop:disable Metrics/MethodLength
    examples.each do |example|
      id = identifier.call(example)
      actual_value = actual.call(example)
      predicted_value = prediction.call(example)

      if actual_value == predicted_value
        puts "✅ #{id} (#{predicted_value})"
      else
        puts "🛑 #{id} (#{predicted_value})"
        puts "  -> expected #{actual_value}"

        if fix
          begin
            print "Enter new value (Ctrl-D to ignore): "
            new_value = gets&.chomp
            puts
            fix.call(example, new_value) if new_value
          rescue StandardError => e
            puts "Couldn't update value (#{e})"
          end
        end
      end
    end
  end
end
