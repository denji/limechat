require File.expand_path('../../test_helper', __FILE__)
require 'preferences'

class Preferences
  class TestDefaults < Preferences::AbstractPreferencesSection
    defaults_accessor :an_option, true
    string_array_defaults_accessor :an_array, %w{ foo bar baz }, 'TestDefaultsStringWrapper'
  end
  register_default_values!
end

describe "Preferences" do
  it "should be a singleton" do
    Preferences.should.include Singleton
    Preferences.instance.should.be.instance_of Preferences
  end
  
  it "should have defined a shortcut method on Kernel" do
    preferences.should.be Preferences.instance
  end
  
  it "should have instances of all section classes" do
    %w{ keyword dcc general sound theme }.each do |section|
      preferences.send(section).class.name.should == "Preferences::#{section.capitalize}"
    end
  end
end

describe "Preferences::AbstractPreferencesSection" do
  before do
    @prefs = Preferences::TestDefaults.instance
  end
  
  it "should know the key in the prefs based on it's section class name" do
    Preferences::TestDefaults.section_defaults_key.should == 'Preferences.TestDefaults'
  end
  
  it "should should add default values to the Preferences.default_values" do
    Preferences.default_values['Preferences.TestDefaults.an_option'].should == true
  end
  
  it "should register user defaults with ::defaults_accessor" do
    @prefs.an_option.should == true
    @prefs.an_option = false
    @prefs.an_option.should == false
  end
  
  it "should return an array of wrapped strings for a string_array_defaults_accessor" do
    assert @prefs.an_array_wrapped.all? { |x| x.is_a? TestDefaultsStringWrapper }
    @prefs.an_array_wrapped.map { |x| x.valueForKey('string') }.should == %w{ foo bar baz }
  end
  
  it "should return the key path for the defaults_accessor" do
    Preferences::TestDefaults.defaults_accessor(:an_accessor, '').should == 'Preferences.TestDefaults.an_accessor'
  end
end

describe "A Preferences::StringArrayWrapper subclass" do
  before do
    @prefs = Preferences::TestDefaults.instance
  end
  
  after do
    @prefs.an_array = %w{ foo bar baz }
  end
  
  it "should be a subclass of Preferences::StringArrayWrapper" do
    TestDefaultsStringWrapper.superclass.should.be Preferences::StringArrayWrapper
  end
  
  it "should know it's key path" do
    TestDefaultsStringWrapper.key_path.should == 'Preferences.TestDefaults.an_array'
  end
  
  it "should update the string it wraps in the array at the configured key path" do
    @prefs.an_array_wrapped.first.string = 'new_foo'
    @prefs.an_array.should == %w{ new_foo bar baz }
    
    @prefs.an_array_wrapped.last.string = 'new_baz'
    @prefs.an_array.should == %w{ new_foo bar new_baz }
  end
  
  it "should add the string it wraps to the array at the configured key path if initialized without index, this happens when a NSArrayController initializes an instance" do
    wrapper = TestDefaultsStringWrapper.alloc.init
    wrapper.string = 'without index'
    @prefs.an_array.last.should == 'without index'
    wrapper.index.should == 3
  end
  
  it "should remove the strings the wrappers wrap from the array at the configured key path and reset the indices of the wrappers" do
    wrapped = @prefs.an_array_wrapped
    new_wrapped = [wrapped[1]]
    Preferences::StringArrayWrapper.destroy(TestDefaultsStringWrapper, new_wrapped)
    @prefs.an_array.should == %w{ bar }
    new_wrapped.first.index.should == 0
  end
end

class ClassThatIncludesStringArrayWrapperHelper < OSX::NSObject
  extend Preferences::StringArrayWrapperHelper
  
  string_array_wrapper_accessor :a_kvc_array, 'Preferences::TestDefaults.instance.an_array'
end

describe "A class that extends with Preferences::StringArrayWrapperHelper" do
  before do
    @instance = ClassThatIncludesStringArrayWrapperHelper.alloc.init
  end
  
  after do
    Preferences::TestDefaults.instance.an_array = %w{ foo bar baz }
  end
  
  it "should define a kvc_accessor" do
    @instance.valueForKey('a_kvc_array').map { |x| x.string }.should == %w{ foo bar baz }
  end
  
  it "should remove wrappers from the preferences which are removed from the array given to the kvc setter" do
    Preferences::TestDefaults.instance.an_array = %w{ foo bar baz bla boo }
    
    2.times do
      wrappers = Preferences::TestDefaults.instance.an_array_wrapped
      wrappers.delete_at(1)
      @instance.a_kvc_array = wrappers
    end
    
    @instance.a_kvc_array.map { |x| x.string }.should == %w{ foo bla boo }
  end
end
