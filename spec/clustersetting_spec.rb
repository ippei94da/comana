#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/clustersetting.rb"

describe Comana::ClusterSetting do
  context "exist clustersetting file" do
    before do
      @mi00 = Comana::ClusterSetting.new({
        "pbs_server" => "P00",
        "groups" => {
          "A" => {
            "data1" => "A-1",
            "data2" => "A-2", 
            "members" => ["A00", "A01"]
          },
          "B" => {
            "data1" => "B-1",
            "data2" => "B-2",
            "members" => ["B00", "B01", "B02"]
          },
          "C" => { #No member
            "data1" => "A-1",
            "data2" => "A-2", 
          },
        }
      })
    end

    describe "#load_file" do
      it do
        @mi00.pbs_server.should == "P00"
      end
    end

    describe "#load_file" do
      DATA_FILE = "example/dot.clustersetting"
      it do
        lambda{Comana::ClusterSetting.load_file(DATA_FILE)}.should_not raise_error
      end

      mi00 = Comana::ClusterSetting.load_file(DATA_FILE)
      mi00.groups.should == {
        "A" => {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        },
        "B" => {
          "data1" => "B-1",
          "data2" => "B-2",
          "members" => ["B00", "B01", "B02"]
        },
      }
    end

    describe "#belonged_cluster" do
      it do
        @mi00.belonged_cluster("A00").should == "A"
        @mi00.belonged_cluster("A01").should == "A"
        @mi00.belonged_cluster("B00").should == "B"
        @mi00.belonged_cluster("B01").should == "B"
        @mi00.belonged_cluster("B02").should == "B"
        @mi00.belonged_cluster("NONE").should == nil
      end
    end

    describe "#settings_group" do
      it do
        @mi00.settings_group("A").should == {
          "data1" => "A-1",
          "data2" => "A-2", 
          "members" => ["A00", "A01"]
        }
        @mi00.settings_group("B").should == {
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
        @mi00.clusters.should == ["A", "B", "C"]
      end
    end
  end

  context "not exist clustersetting file" do
    it do
      lambda{ Comana::ClusterSetting.load_file("") }.should raise_error(Errno::ENOENT)
    end
  end

end

