namespace :cf do
  desc "Only run on the first application instance"
  task :on_first_instance do
    exit(0) unless ENV["CF_INSTANCE_INDEX"].to_i.zero?
  end
end
