module PolymorphicModel
  module Initializer
    def polymorphic_model(options = {})
      if options[:with_type_column]
        @_polymorphic_column = options[:with_type_column]
        @_model_types = []
        extend PolymorphicModel::ClassMethods
      end
    end
  end

  module ClassMethods
    def types
      @_model_types.clone.freeze
    end

    def validates_type
      validates_each @_polymorphic_column, {:on => :save} do |record, attr_name, value|
        unless value.nil? || value == ""
          unless self.types.include?(value.to_sym)
            record.errors.add_to_base("is undefined type (#{value.to_s}), correct types are: [#{self.types.map(&:to_s).join(', ')}]")
          end
        else
          record.errors.add_to_base("is not any type, correct types are: [#{self.types.map(&:to_s).join(', ')}]")
        end
      end
    end

    def define_type(t, options = {})
      column = @_polymorphic_column
      @_model_types << t.to_sym
      define_method :"#{t.to_s}?" do
        send(column) == t.to_s
      end

      validates_type
      
      condition_hash = {column => t.to_s}
      if options[:singleton] == true
        validates_uniqueness_of column, :if => :"#{t}?"
        self.class.instance_eval do
          define_method t do
            scope = scoped(:conditions => condition_hash)
            scope.first || (options[:autocreate] ? create!(condition_hash) : scope)
          end
        end
      else
        named_scope(t, :conditions => condition_hash)
      end
    end
  end
end

require 'rubygems'
require 'active_record'
class ActiveRecord::Base
  extend PolymorphicModel::Initializer
end