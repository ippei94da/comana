#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
require "fileutils"

class TC_ClusterSetting < Test::Unit::TestCase
  def setup
    @mi00 = Comana::ClusterSetting.new({
      "pbs_server" => "P00",
      "groups" => {
        "A" => {
          "data1" => "A-1",
          "data2" => "A-2", 
          "queue" => "A.q", 
          "members" => ["A00", "A01"]
        },
        "B" => {
          "data1" => "B-1",
          "data2" => "B-2",
          "queue" => "B.q", 
          "members" => ["B00", "B01", "B02"]
        },
        "C" => { #No member
          "data1" => "A-1",
          "data2" => "A-2", 
          "queue" => "C.q", 
        },
      }
    })
  end

  def test_load_file
    assert_equal("P00", @mi00.pbs_server)

    data_file = "example/dot.clustersetting"
    assert_nothing_raised{ Comana::ClusterSetting.load_file(data_file) }
    assert_raise(Errno::ENOENT){ Comana::ClusterSetting.load_file("") }
  end

  def test_belonged_cluster
    assert_equal("A" , @mi00.belonged_cluster("A00"))
    assert_equal("A" , @mi00.belonged_cluster("A01"))
    assert_equal("B" , @mi00.belonged_cluster("B00"))
    assert_equal("B" , @mi00.belonged_cluster("B01"))
    assert_equal("B" , @mi00.belonged_cluster("B02"))
    assert_raise(Comana::ClusterSetting::NoEntryError){ @mi00.settings_host("NONE")}
  end

  def test_settings_group
    assert_equal(
      {
        "data1" => "A-1",
        "data2" => "A-2", 
        "queue" => "A.q", 
        "members" => ["A00", "A01"]
      },
      @mi00.settings_group("A")
    )

    assert_equal(
      {
        "data1" => "B-1",
        "data2" => "B-2",
        "queue" => "B.q", 
        "members" => ["B00", "B01", "B02"]
      },
      @mi00.settings_group("B")
    )
  end

  def test_settings_queue
    results = @mi00.settings_queue('A.q')
    corrects = {
        "data1" => "A-1",
        "data2" => "A-2", 
        "queue" => "A.q", 
        "members" => ["A00", "A01"]
    }
    assert_equal(corrects, results)
  end

  def test_settings_host
    assert_equal(
      {
        "data1" => "A-1",
        "data2" => "A-2", 
        "queue" => "A.q", 
        "members" => ["A00", "A01"]
      },
      @mi00.settings_host("A00")
    )

    assert_equal(
      {
        "data1" => "B-1",
        "data2" => "B-2",
        "queue" => "B.q", 
        "members" => ["B00", "B01", "B02"]
      },
      @mi00.settings_host("B00")
    )

    assert_raise(Comana::ClusterSetting::NoEntryError){ @mi00.settings_host("NONE")}
  end

  def test_clusters
    assert_equal(["A", "B", "C"], @mi00.clusters)
  end

end

