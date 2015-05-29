#! /usr/bin/env ruby
# coding: utf-8
#
require "yaml"

class Comana::HostInspector
  PING_MIN_INTERVAL = 1

  CACHE_DIR = "#{ENV['HOME']}/var/comana"

  attr_reader :hostname

  #
  def initialize(hostname)
    @hostname = hostname
    @cache_dir = "#{CACHE_DIR}/#{@hostname}"
  end

  #Try ping three times.
  #Return true if at least one time responds.
  #def ping3
  def update_ping
    result = false
    3.times do
      command =
        "ping -c 1 -W #{PING_MIN_INTERVAL} #{@hostname} 2> /dev/null 1> /dev/null"
      if system(command)
        result = true
        break
      end
    end

    write_cache("ping", result)
  end

  #Return from cached ping data.
  def fetch_ping
    #pp load_cache('ping')
    #exit
    load_cache('ping')
  end

  def time_updated(name)
    ping_file = "#{@cache_dir}/#{name}.yaml"
    if File.exist?  ping_file
      return File.mtime(ping_file)
    else
      return nil
    end
  end

  private

  def write_cache(name, value)
    FileUtils.mkdir_p @cache_dir
    File.open("#{@cache_dir}/#{name}.yaml", "w") do |io|
      YAML.dump(value, io)
    end
  end

  def load_cache(name)
    return nil unless File.exist? "#{@cache_dir}/#{name}.yaml"
    YAML.load_file("#{@cache_dir}/#{name}.yaml")
  end

end

