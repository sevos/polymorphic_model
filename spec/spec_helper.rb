$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'polymorphic_model'
require 'spec'
require 'spec/autorun'
require 'lib/database'

Spec::Runner.configure do |config|
  config.before(:each) { set_database(["job", "offer"])  }
end
