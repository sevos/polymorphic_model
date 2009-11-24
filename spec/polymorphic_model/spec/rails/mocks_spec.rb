require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Spec::Rails::Mocks" do
  require 'spec/rails/polymorphic_model'
  include Spec::Rails::Mocks

  describe :mock_polymorphic_model do
    before(:all) do
      set_database(["task"])
      class Task < ActiveRecord::Base
        polymorphic_model :with_type_column => "task_type"
        define_type :internal
        define_type :external 
      end
    end

    it "should stub check-methods" do
      mock = mock_polymorphic_model(Task, :external)
      mock.should be_external
      mock.should_not be_internal
    end

    it "should should stub type-column value" do
      mock = mock_polymorphic_model(Task, :internal)
      mock.task_type.should == "internal"
    end

    it "should not allow mock model with incorrect type" do
      lambda do
        mock_polymorphic_model(Task, :invalid) 
      end.should raise_error(Spec::Rails::Mocks::InvalidPolymorphicModelTypeError)
    end

  end
end