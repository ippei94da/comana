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
    ping_file = "#{CACHE_DIR}/#{@h00.hostname}/ping.yaml"
    #FileUtils.rm_rf "#{CACHE_DIR}/#{@h00.hostname}"
    FileUtils.rm ping_file if File.exist?(ping_file)
    assert_equal(false, File.exist?(ping_file))
    @h00.update_ping
    assert_equal(true, File.exist?(ping_file))
    assert_equal(true, YAML.load_file(ping_file))

    ping_file = "#{CACHE_DIR}/#{@h01.hostname}/ping.yaml"
    FileUtils.rm ping_file if File.exist?(ping_file)
    assert_equal(false, File.exist?(ping_file))
    @h01.update_ping
    assert_equal(true, File.exist?(ping_file))
    assert_equal(false, YAML.load_file(ping_file))
  end

  def test_update_cwd
    cwd_file = "#{CACHE_DIR}/#{@h00.hostname}/cwd.yaml"
    FileUtils.rm cwd_file if File.exist?(cwd_file)
    assert_equal(false, File.exist?(cwd_file))
    @h00.update_cwd
    assert_equal(true, File.exist?(cwd_file))
    assert_equal(Hash, YAML.load_file(cwd_file).class)

    cwd_file = "#{CACHE_DIR}/#{@h01.hostname}/cwd.yaml"
    FileUtils.rm cwd_file if File.exist?(cwd_file)
    assert_equal(false, File.exist?(cwd_file))
    @h01.update_cwd
    assert_equal(true, File.exist?(cwd_file))
    assert_equal(Hash, YAML.load_file(cwd_file).class)
  end

  def test_fetch
    @h00.update_ping
    assert_equal(true, @h00.fetch('ping'))

    @h01.update_ping
    assert_equal(false, @h01.fetch('ping'))

    assert_equal(nil, Comana::HostInspector.new("undone_update").fetch('ping'))

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

