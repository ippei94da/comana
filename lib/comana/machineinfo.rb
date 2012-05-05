#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

#
#
#
class MachineInfo

  class NoEntryError < Exception; end

  #
  def initialize(data)
    @data = data
  end

  def self.load_file(data_file)
    #pp data_file
    #pp ENV["PWD"]
    #pp File.open(DATA_FILE, "r").readlines
    data = YAML.load_file(data_file)
    MachineInfo.new data
    #pp @data
  end

  def get_host(host)
    raise NoEntryError unless @data.has_key?(host)
    @data[host]
  end

end

