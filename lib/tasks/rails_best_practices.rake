require 'rails_best_practices'

desc 'Execute rails_best_practices'
task :rbp do
  analyzer = RailsBestPractices::Analyzer.new('.')
  analyzer.analyze
  puts analyzer.output
end
