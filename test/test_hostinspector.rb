#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"


class Comana::HostInspector
  CACHE_DIR = "test/hostinspector/var"
end

class TC_HostInspector < Test::Unit::TestCase
  CACHE_DIR = Comana::HostInspector::CACHE_DIR 

  def setup
      @h00 = Comana::HostInspector.new("localhost")
      @h01 = Comana::HostInspector.new("--not_exist_host--")
  end

  def test_update_ping
    FileUtils.rm_rf "#{CACHE_DIR}/#{@h00.hostname}"
    assert_equal(false, File.exist?("#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"))
    #sleep 60
    @h00.update_ping
    pp "#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"
    assert_equal(true, File.exist?("#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"))
    assert_equal(true, YAML.load_file("#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"))

    FileUtils.rm_rf "#{CACHE_DIR}/#{@h01.hostname}"
    assert_equal(false, File.exist?("#{CACHE_DIR}/#{@h01.hostname}/ping.yaml"))
    #sleep 60
    @h01.update_ping
    pp "#{CACHE_DIR}/#{@h01.hostname}/ping.yaml"
    assert_equal(true, File.exist?("#{CACHE_DIR}/#{@h01.hostname}/ping.yaml"))
    assert_equal(false, YAML.load_file("#{CACHE_DIR}/#{@h01.hostname}/ping.yaml"))
  end

  def test_fetch_ping
    @h00.update_ping
    assert_equal(true, @h00.fetch_ping)

    @h01.update_ping
    assert_equal(false, @h01.fetch_ping)

    assert_equal(nil, Comana::HostInspector.new("undone_update").fetch_ping)

  end

  def test_time_ping
    time = Time.local(2015, 5, 29, 22, 00, 17)
    ping_file = "#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"
    #pp File.mtime(ping_file)
    File::utime(time, time, ping_file)
    #pp File.mtime(ping_file)
    assert_equal(time, File.mtime(ping_file))
  end

end

