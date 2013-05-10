#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "helper"

$TEST = true

#describe Comana::HostInspector::do
class TC_Pbsnodes < Test::Unit::TestCase

  def setup
    #context 'alive host' do
    @p00 = Comana::HostInspector::Pbsnodes.new("Br10")

    #context 'exist and alive' do
    @p01 = Comana::HostInspector::Pbsnodes.new("Br09")
  end

  def test_state
    assert_equal("Br10", @p00.name)
    assert_equal("free", @p00.state)
    assert_equal("1", @p00.np)
    assert_equal("Br", @p00.properties)
    assert_equal("cluster", @p00.ntype)
    assert_equal(
      {
        "rectime"   => "1368099478",
        "varattr"   => "",
        "jobs"      => "",
        "state"     => "free",
        "netload"   => "1636471502",
        "gres"      => "",
        "loadave"   => "0.00",
        "ncpus"     => "4",
        "physmem"   => "12322444kb",
        "availmem"  => "20402856kb",
        "totmem"    => "20702856kb",
        "idletime"  => "1389153",
        "nusers"    => "0",
        "nsessions" => "? 0",
        "sessions"  => "? 0",
        "uname"     => "Linux Br10 3.0.0-12-server #20-Ubuntu SMP Fri Oct 7 16:36:30 UTC 2011 x86_64",
        "opsys"     => "linux"
      },
      @p00.status
    )
    assert_equal("0", @p00.gpus)

    assert_equal("Br09",@p01.name)
    assert_equal("down",@p01.state)
    assert_equal("1",@p01.np)
    assert_equal("Br",@p01.properties)
    assert_equal("cluster",@p01.ntype)
    assert_equal({},@p01.status)
    assert_equal("0",@p01.gpus)
  end
end

