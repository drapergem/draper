notification :gntp, host: '127.0.0.1'

def rspec_guard(options = {}, &block)
  opts = {
    :cmd => 'rspec'
  }.merge(options)

  guard 'rspec', opts, &block
end

rspec_guard :spec_paths => %w{spec/draper spec/generators} do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

rspec_guard :spec_paths => ['spec/integration'], cmd: 'RAILS_ENV=development rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

rspec_guard :spec_paths => ['spec/integration'], cmd: 'RAILS_ENV=production rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

#  vim: set ts=8 sw=2 tw=0 ft=ruby et :
