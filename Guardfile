def rspec_guard(options = {}, &block)
  options = {
    :version => 2,
    :notification => false
  }.merge(options)

  guard 'rspec', options, &block
end

rspec_guard :spec_paths => %w{spec/draper spec/generators} do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

rspec_guard :spec_paths => 'spec/integration', :env => {'RAILS_ENV' => 'development'} do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

rspec_guard :spec_paths => 'spec/integration', :env => {'RAILS_ENV' => 'production'} do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
