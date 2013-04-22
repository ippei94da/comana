#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/clustersetting.rb"

describe Comana::ClusterSetting do
  context "exist clustersetting file" do
    before do
      @mi00 = Comana::ClusterSetting.new({
        "GroupA" => {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        },
        "GroupB" => {
          "data1" => "B-1",
          "data2" => "B-2",
          "members" => ["B00", "B01", "B02"]
        },
      })
    end

    describe "#load_file" do
      DATA_FILE = "example/dot.clustersetting"
      it do
        lambda{Comana::ClusterSetting.load_file(DATA_FILE)}.should_not raise_error
      end

      mi00 = Comana::ClusterSetting.load_file(DATA_FILE)
      mi00.groups_settings.should == {
        "GroupA" => {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        },
        "GroupB" => {
          "data1" => "B-1",
          "data2" => "B-2",
          "members" => ["B00", "B01", "B02"]
        },
      }
    end

    describe "#belonged_cluster" do
      it do
        @mi00.belonged_cluster("A00").should == "GroupA"
        @mi00.belonged_cluster("A01").should == "GroupA"
        @mi00.belonged_cluster("B00").should == "GroupB"
        @mi00.belonged_cluster("B01").should == "GroupB"
        @mi00.belonged_cluster("B02").should == "GroupB"
        @mi00.belonged_cluster("NONE").should == nil
      end
    end

    describe "#settings_group" do
      it do
        @mi00.settings_group("GroupA").should == {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        }
        @mi00.settings_group("GroupB").should == {
          "data1" => "B-1",
          "data2" => "B-2",
          "members" => ["B00", "B01", "B02"]
        }
      end
    end

    describe "#settings_host" do
      it do
        @mi00.settings_host("A00").should == {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        }
        @mi00.settings_host("B00").should == {
          "data1" => "B-1",
          "data2" => "B-2",
          "members" => ["B00", "B01", "B02"]
        }
        @mi00.settings_host("NONE").should == nil
      end
    end

    describe "#clusters" do
      it do
        @mi00.clusters.should == ["GroupA", "GroupB"]
      end
    end
  end

  context "not exist clustersetting file" do
    it do
      lambda{ Comana::ClusterSetting.load_file("") }.should raise_error(Errno::ENOENT)
    end
  end

  #describe "#get_info" do
  #  before do
  #    @mi00 = Comana::ClusterSetting.new({
  #      "GroupA" => { "data1" => "A-1", "data2" => "A-2" },
  #      "GroupB" => { "data1" => "B-1", "data2" => "B-2" },
  #    })
  #  end

  #  context "mach to hostname in data" do
  #    #@mi00.get_info("GroupA"). should == { "data1" => "A-1", "data2" => "A-2" }
  #    subject { @mi00.get_info("GroupA") }
  #    it {should == { "data1" => "A-1", "data2" => "A-2" } }
  #    #subject { @mi00.get_info("GroupB") }
  #    #it {should == { "data1" => "B-1", "data2" => "B-2" } }
  #  end

  #  context "Group name + integers" do
  #    subject { @mi00.get_info("GroupA00") }
  #    it {should == { "data1" => "A-1", "data2" => "A-2" } }
  #  end

  #  context "Group name + alphabet" do
  #    it {lambda{@mi00.get_info("GroupAB")}.should raise_error(Comana::ClusterSetting::NoEntryError)}
  #  end

  #  context "no entry" do
  #    it {lambda{@mi00.get_info("")}.should raise_error(Comana::ClusterSetting::NoEntryError)}
  #  end
  #end

end

