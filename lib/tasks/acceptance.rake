desc 'Run acceptance tests (tests + rbp + rubocop)'
task :acceptance do
  system('bin/rake test RAILS_ENV=test') || fail('Tests [FAILED]')
  %w[rubocop rbp].each do |name|
    Rake::Task[name].reenable
    Rake::Task[name].invoke
  end
end
