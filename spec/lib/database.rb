require 'rubygems'
require 'activerecord'
require 'logger'

DATABASE_CONFIG = {
  :adapter => 'sqlite3',
  :database => ':memory:'
}.freeze

def set_database(table_names)
  ActiveRecord::Base.establish_connection(DATABASE_CONFIG)
  #ActiveRecord::Base.logger = Logger.new(STDERR)
  table_names.each do |table_name|
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :"#{table_name.pluralize}" do |t|
          t.string :"#{table_name}_type"

          t.string :title
          t.string :url
          t.text   :description

          t.timestamps
        end
      end
    end

    eval %{
      class #{table_name.capitalize} < ActiveRecord::Base
      end
    }
  end
end
