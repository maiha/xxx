
require 'spec'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

RACK_ENV = :test

require File.join(File.dirname(__FILE__), '/its_helper')
require File.join(File.dirname(__FILE__), '/provide_helper')

def path(key)
  Pathname(File.join(File.dirname(__FILE__) + "/fixtures/#{key}"))
end

def data(key)
  (@__fixture_data_cache__ ||= {})[key] ||= path(key).read{}
end

require 'pathname'
def load_dir(dir)
  dir = dir.to_s
  dir = Pathname(dir[0] == ?/ ? dir : File.join(File.dirname(__FILE__), '..', dir))
  dir = dir.expand_path

  files = []
  files = Dir.glob("#{dir}/**/*.rb").sort if dir.directory?
  files.unshift(dir) if File.exist?(dir.to_s.gsub(/(\.rb)?$/, '') + '.rb')

  files.each do |file|
    require file
  end
end
