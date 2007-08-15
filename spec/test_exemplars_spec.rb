require File.dirname(__FILE__) + '/spec_helper'
require "test_exemplars"

class Chicken < ActiveRecord::Base
  attr_protected :ssn
end

describe ExemplarBuilder do
  include ExemplarBuilder
  
  it "should return a blank object when exemplified with no defaults" do
    exemplify Chicken
    Chicken.exemplar.name.should be_blank
    Chicken.exemplar.age.should be_blank
  end
  
  it "should return a filled object when defaults are given" do
    exemplify Chicken, :name => "chicken little", :age => 10
    Chicken.exemplar.name.should == "chicken little"
    Chicken.exemplar.age.should == 10
  end
  
  it "should allow setting an exemplar's attributes in a block" do
    exemplify Chicken, :ssn => "abc123"
    Chicken.exemplar.ssn.should be_blank
    exemplify(Chicken) {|c| c.ssn = "abc123" }
    Chicken.exemplar.ssn.should == "abc123"
  end
  
  it "should allow you to override an exemplar's attributes" do
    exemplify Chicken, :name => "chicken little", :age => 10
    c = Chicken.exemplar :name => "amazing"
    c.name.should == "amazing"
    c.age.should == 10
  end
  
  it "should build and save an exemplar with create_exemplar" do
    exemplify Chicken
    lambda { Chicken.create_exemplar }.should change(Chicken, :count).by(1)
  end
  
  it "should raise an error when create_exemplar! is called and the record can't be saved" do
    class Chicken
      validates_presence_of :name, :age
    end
    
    exemplify Chicken, :name => "lame name"
    lambda { Chicken.create_exemplar! :name => "really lame" }.should raise_error
  end
  
  it "should allow for automatically populating an attribute based on exemplar count" do
    exemplify Chicken, :auto_id => :name, :age => 10
    Chicken.create_exemplar!.name.should == "Chicken1"
    Chicken.create_exemplar!.name.should == "Chicken2"
  end
  
  it "should create different objects in succession" do
    exemplify Chicken, :name => "yeah baby", :age => 100
    Chicken.create_exemplar!.should_not == Chicken.create_exemplar!
  end
  
  it "should allow you to create an exemplar without validations" do
    class Chicken
      validates_presence_of :name, :age
    end
    
    exemplify Chicken
    Chicken.create_exemplar.errors.should_not be_blank
    Chicken.create_exemplar(:perform_validation => false).should have(:no).errors
  end
end