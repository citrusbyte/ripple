# A sample Guardfile
# More info at https://github.com/guard/guard#readme
gemset = ENV['RVM_GEMSET'] || 'ripple'
gemset = "@#{gemset}" unless gemset.to_s == ''

rvms = %w[1.9.2 1.9.3 2.0.0 jruby ].map do |version|
  "#{version}@#{gemset}"
end

guard 'rspec', :cli => '--profile', :rvm => rvms do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec/ripple" }
end
