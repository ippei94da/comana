#! /usr/bin/env ruby
# coding: utf-8

require "helper"

class Comana::HostSelector
  attr_reader :groups_hosts
end

class TC_HostSelector < Test::Unit::TestCase
  def setup
    groups_hosts = {
      "GroupA" => ["A00", "A01"],
      "GroupB" => ["B00", "B01", "B02"]
    }
    @hs00 = Comana::HostSelector.new(groups_hosts)

    groups_hosts = {
      "GroupNil" => nil,
      "GroupA" => ["A00", "A01"],
      "GroupB" => ["B00", "B01", "B02"]
    }
    @hs01 = Comana::HostSelector.new(groups_hosts)
  end

  def test_load_file
    hs = Comana::HostSelector.load_file("test/hostselector/dot.clustersetting")
    assert_equal(Comana::HostSelector, hs.class)
    assert_equal({"A"=>["A00", "A01"], "B"=>["B00", "B01", "B02"]}, hs.groups_hosts)
  end

  def test_select_all
    assert_equal(["A00", "A01", "B00", "B01", "B02"], @hs00.select_all)
    assert_equal(["A00", "A01", "B00", "B01", "B02"], @hs01.select_all)
  end

  def test_select_group
    assert_equal(["A00", "A01"], @hs00.select_group("GroupA"))
    assert_raise(Comana::HostSelector::NoEntryError){ @hs00.select_group("GroupNil") }
  end

  def test_groups
    assert_equal(["GroupA", "GroupB"], @hs00.groups)
  end
end

