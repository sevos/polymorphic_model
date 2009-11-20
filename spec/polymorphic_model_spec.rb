require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'lib/job_model'

describe "PolymorphicModel" do
  before(:all) do
    Job.instance_eval do
      polymorphic_model :with_type_column => :job_type
    end
  end

  it "should create define_type method" do
    Job.methods.should include("define_type")
  end

  describe :define_type do
    before do
      Job.instance_eval do
        define_type :some_type
      end
    end
    
    it "should create check methods" do
      Job.instance_methods.should include("some_type?")
    end
  end
end

describe "When normal collection types are defined" do
  before do
    Job.instance_eval do
      define_type :internal
      define_type :external
    end
    2.times { @external = Job.create(:job_type => "external") }
    3.times { @internal = Job.create(:job_type => "internal") }
  end
  
  describe "check methods" do
    it "should return true if object is in kind of method" do
      @external.should be_external
      @internal.should be_internal
      @external.should_not be_internal
      @internal.should_not be_external          
    end
  end
    
  describe "named scopes" do
    it "should return correct collections" do
      Job.external.count.should == 2
      Job.internal.count.should == 3
    end
  end
  
  after do
    Job.destroy_all
  end
end
    
describe "When singleton type is defined" do
  describe "with autocreate" do
    before do
      Job.instance_eval do
        define_type :basic, :singleton => true, :autocreate => true  
      end
    end
    
    describe "when object doesn't exist yet" do
      before do
        Job.destroy_all
      end
      
      it "should create object" do
        Job.basic.should be_basic
      end
    end
    
    describe "when object exists" do
      before do
        Job.basic
      end
      
      it "should not allow to create another instance of object" do
        Job.new(:job_type => "basic").should_not be_valid
      end
    end
  end

end
