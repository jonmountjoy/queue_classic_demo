desc "Start a queue worker"
task :work => :environment do
  DemoWorker.new.start
end