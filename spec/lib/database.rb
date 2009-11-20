require 'rubygems'
require 'activerecord'
require 'logger'

DATABASE_CONFIG = {
  :adapter => 'sqlite3',
  :database => ':memory:'
}.freeze
def set_database
  ActiveRecord::Base.establish_connection(DATABASE_CONFIG)
  #ActiveRecord::Base.logger = Logger.new(STDERR)
  
  ActiveRecord::Schema.define do
    create_table :jobs do |t|
      t.string :job_type
  
      t.string :title
      t.string :url
      t.text   :description
  
      t.timestamps
    end
  end
end
require 'lib/job_model'