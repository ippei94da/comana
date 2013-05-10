#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"

#require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
#require "comana/clustersetting.rb"

class TC_ClusterSetting < Test::Unit::TestCase
  def setup
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

  def test_load_file
    assert_equal("P00", @mi00.pbs_server)

    data_file = "example/dot.clustersetting"
    assert_nothing_raised{
      Comana::ClusterSetting.load_file(data_file)
    }

    #context "not exist clustersetting file" do
    assert_raise(Errno::ENOENT){ Comana::ClusterSetting.load_file("") }
  end

    #mi00 = Comana::ClusterSetting.load_file(data_file)
    #mi00.groups.should == {
    #  "A" => {
    #    "data1" => "A-1",
    #    "data2" => "A-2", 
    #    "members" => ["A00", "A01"]
    #  },
    #  "B" => {
    #    "data1" => "B-1",
    #    "data2" => "B-2",
    #    "members" => ["B00", "B01", "B02"]
    #  },
    #}

  def test_belonged_cluster
    assert_equal("A" , @mi00.belonged_cluster("A00"))
    assert_equal("A" , @mi00.belonged_cluster("A01"))
    assert_equal("B" , @mi00.belonged_cluster("B00"))
    assert_equal("B" , @mi00.belonged_cluster("B01"))
    assert_equal("B" , @mi00.belonged_cluster("B02"))
    assert_equal( nil, @mi00.belonged_cluster("NONE"))
  end

  def test_settings_group
    assert_equal(
      {
        "data1" => "A-1",
        "data2" => "A-2", 
        "members" => ["A00", "A01"]
      },
      @mi00.settings_group("A")
    )

    assert_equal(
      {
        "data1" => "B-1",
        "data2" => "B-2",
        "members" => ["B00", "B01", "B02"]
      },
      @mi00.settings_group("B")
    )
  end

  def test_settings_host
    assert_equal(
      {
        "data1" => "A-1",
        "data2" => "A-2", 
        "members" => ["A00", "A01"]
      },
      @mi00.settings_host("A00")
    )

    assert_equal(
      {
        "data1" => "B-1",
        "data2" => "B-2",
        "members" => ["B00", "B01", "B02"]
      },
      @mi00.settings_host("B00")
    )

    assert_equal(nil, @mi00.settings_host("NONE"))
  end

  def test_clusters
    assert_equal(["A", "B", "C"], @mi00.clusters)
  end

end

