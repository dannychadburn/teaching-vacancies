class Runner
  attr_reader :examples, :labels, :actual, :prediction, :identifier, :fix

  def initialize(examples, labels:, actual:, prediction:, identifier:, fix: nil)
    @examples = examples
    @labels = labels
    @actual = actual
    @prediction = prediction
    @identifier = identifier
    @fix = fix
  end

  def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
    true_positives = Hash.new(0)
    false_positives = Hash.new(0)
    true_negatives = Hash.new(0)
    false_negatives = Hash.new(0)

    examples.each do |example|
      id = identifier.call(example)
      actual_value = actual.call(example)
      predicted_value = prediction.call(example)

      if actual_value == predicted_value
        puts "✅ #{id} (#{actual_value})"

        true_positives[actual_value] += 1
        (labels - [actual_value]).each { |l| true_negatives[l] += 1 }
      else
        puts "🛑 #{id}"
        puts "  -> actual is '#{actual_value}', but predicted '#{predicted_value}'"

        false_positives[predicted_value] += 1
        false_negatives[actual_value] += 1
        (labels - [actual_value, predicted_value]).each { |l| true_negatives[l] += 1 }

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

    correct_predictions = true_positives.values.sum
    accuracy = (correct_predictions.to_f / examples.count).ceil(4)
    puts "\nAccuracy: #{accuracy} (#{correct_predictions}/#{examples.count})"

    precisions = labels
      .select { |l| (true_positives[l] + false_positives[l]).positive? }
      .to_h { |l| [l, true_positives[l].to_f / (true_positives[l] + false_positives[l])] }
    puts "Precision per label:"
    precisions.each do |label, precision|
      puts "  #{label}: #{precision.ceil(4)}"
    end

    recalls = labels
      .select { |l| (true_positives[l] + false_negatives[l]).positive? }
      .to_h { |l| [l, true_positives[l].to_f / (true_positives[l] + false_negatives[l])] }
    puts "Recall per label:"
    recalls.each do |label, recall|
      puts "  #{label}: #{recall.ceil(4)}"
    end

    specificities = labels
      .select { |l| (true_negatives[l] + false_positives[l]).positive? }
      .to_h { |l| [l, true_negatives[l].to_f / (true_negatives[l] + false_positives[l])] }
    puts "Specificity per label:"
    specificities.each do |label, specificity|
      puts "  #{label}: #{specificity.ceil(4)}"
    end

    # puts true_positives.inspect
    # puts false_positives.inspect
    # puts true_negatives.inspect
    # puts false_negatives.inspect
  end
end
