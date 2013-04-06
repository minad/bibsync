begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception
end

require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
  t.ruby_opts << '-w' << '-v'
end

task :default => :test
