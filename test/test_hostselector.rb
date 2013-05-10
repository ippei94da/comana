#! /usr/bin/env ruby
# coding: utf-8

require "helper"

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

  def test_select_all
    #it 'should return all hosts' do
    assert_equal(["A00", "A01", "B00", "B01", "B02"], @hs00.select_all)

    #it 'should return all hosts without nil' do
    assert_equal(["A00", "A01", "B00", "B01", "B02"], @hs01.select_all)
  end

  def test_select_group
    #it 'should return hosts in GroupA' do
    assert_equal(["A00", "A01"], @hs00.select_group("GroupA"))

    #it 'should raise Comana::HostSelector::NoEntryError' do
    assert_raise(Comana::HostSelector::NoEntryError){
      @hs00.select_group("GroupNil")
    }
  end

  def test_groups
    #it 'should return all groups' do
    assert_equal(["GroupA", "GroupB"], @hs00.groups)
  end
end

