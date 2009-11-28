require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PolymorphicModel" do
  before(:each) do
    set_database(["job"])
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

    describe :valid_type? do
      it "should return true if type is on list" do
        @job = Job.new(:job_type => "some_type")
        @job.should be_valid_type
      end
      it "should return false if type is not on list" do
        @job = Job.new(:job_type => "incorrect")
        @job.should_not be_valid_type
      end
    end

    it "should allow either string and symbol while setting type via setter" do
      @job = Job.new(:job_type => :some_type)
      @job.job_type.should == "some_type"
      @job.job_type = :other_type
      @job.job_type.should == "other_type"
    end

    it "should create check methods" do
      Job.instance_methods.should include("some_type?")
    end

    it "should create named scope/accessor" do
      Job.methods.should include("some_type")
    end
  end
end

describe "When normal collection types are defined" do
  before do
    set_database(["job"])
    Job.instance_eval do
      polymorphic_model :with_type_column => :job_type
      define_type :internal
      define_type :external
    end
    2.times { @external = Job.create!(:job_type => "external") }
    3.times { @internal = Job.create!(:job_type => "internal") }
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

  it "should allow only defined types" do
    @job = Job.new(:job_type => "other")
    @job.should_not be_valid
  end

  it "should require any type" do
    @job = Job.new
    @job.should_not be_valid
    @job.job_type = ""
    @job.should_not be_valid
  end

  it "should provide list of defined types" do
    Job.types.should include(:internal, :external)
  end
end

describe "When singleton type is defined" do
  describe "with autocreate" do
    before do
      set_database(["job"])
      Job.instance_eval do
        polymorphic_model :with_type_column => :job_type
        define_type :basic, :singleton => true, :autocreate => true  
      end
    end

    describe "when object doesn't exist yet", "accessor" do
      before do
        Job.destroy_all
      end
      it "should create object" do
        Job.basic.should be_basic
        Job.basic.should_not be_new_record
      end
    end

    describe "when object exists", "accessor" do
      before do
        Job.create!(:job_type => "basic")
      end
      it "should return object" do
        Job.basic.should be_instance_of(Job)
      end
      it "should not allow to create another instance of object" do
        Job.new(:job_type => "basic").should_not be_valid
      end
    end
  end

  describe "without autocreate" do
    before do
      set_database(["job"])
      Job.instance_eval do
        polymorphic_model :with_type_column => :job_type
        define_type :basic, :singleton => true, :autocreate => false
      end
    end

    describe "when object doesn't exist yet", "accessor" do
      before do
        Job.destroy_all
      end

      it "should return nil" do
        Job.basic.should be_nil
        Job.basic.should == nil
        Job.basic.should === nil
      end

      it "should allow to create object" do
        Job.basic.create.should be_basic
      end

      it "should allow to create! object" do
        Job.basic.create!.should be_basic
      end

      it "should allow to build object" do
        Job.basic.new.should be_basic
      end
    end

    describe "when object exists", "accessor" do
      before do
        Job.create!(:job_type => "basic")
      end
      it "should return object" do
        Job.basic.should be_instance_of(Job)
      end
      it "should not allow to create another instance of object" do
        Job.new(:job_type => "basic").should_not be_valid
      end
    end

  end
end
