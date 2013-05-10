#! /usr/bin/env ruby
# coding: utf-8

require "helper"

#describe Comana::HostInspector::Ping do
class TC_Ping < Test::Unit::TestCase
  def setup
    #context 'not exist or down' do
    @hi00 = Comana::HostInspector::Ping.new("")

    #context 'exist and alive' do
    @hi01 = Comana::HostInspector::Ping.new("localhost")
  end

  def test_alive?
    assert_equal(false , @hi00.alive?)
    assert_equal(true  , @hi01.alive?)
  end
end

