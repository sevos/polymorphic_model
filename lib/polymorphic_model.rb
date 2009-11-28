module PolymorphicModel
  module Initializer
    # Initializes model to be a polymorphic one
    # Example usage:
    #   polymorphic_model :with_type_column => :page_type 
    def polymorphic_model(options = {})
      if options[:with_type_column]
        @_polymorphic_column = options[:with_type_column].to_sym
        @_polymorphic_column.freeze
        @_model_types = []
        extend PolymorphicModel::ClassMethods
        include PolymorphicModel::InstanceMethods
        self.instance_eval do
          define_method :"#{@_polymorphic_column}=" do |value|
            super(value.to_s)
          end
        end
      end
    end
  end

  module InstanceMethods
    # Returns true if model instance is correct type
    def valid_type?
      self.class.types.include?(send(self.class.polymorphic_column_name).to_sym)
    end
  end

  module ClassMethods
    # Returns list of allowed model types
    def types
      @_model_types.clone.freeze
    end

    def polymorphic_column_name
      @_polymorphic_column
    end

    # Type validation for polymorphic model
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

    # defines new type for model
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
            nil_mock = PolymorphicModel::NilClass.new(self, @_polymorphic_column, t)
            scope.first || (options[:autocreate] ? create!(condition_hash) : nil_mock)
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
require 'polymorphic_model/nil_class'
class ActiveRecord::Base
  extend PolymorphicModel::Initializer
end