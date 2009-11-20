module PolymorphicModel
  module Initializer
    def polymorphic_model(options = {})
      if options[:with_type_column]
        @_polymorphic_column = options[:with_type_column]
        extend PolymorphicModel::ClassMethods
      end
    end
  end

  module ClassMethods
    def define_type(t, options = {})
      column = @_polymorphic_column
      define_method :"#{t.to_s}?" do
        send(column) == t.to_s
      end

      if options[:singleton] == true
        validates_uniqueness_of column, :if => :"#{t}?"
        self.class.instance_eval do
          define_method t do
            existing = find(:first, :conditions => {column => t.to_s})
            if options[:autocreate]
              existing || create!(column => t.to_s)
            else
              existing
            end
          end
          
        end
      else
        named_scope(t, :conditions => { column => "#{t.to_s}" })
      end
    end
  end
end

require 'rubygems'
require 'active_record'
class ActiveRecord::Base
  extend PolymorphicModel::Initializer
end