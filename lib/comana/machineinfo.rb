#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

# Series name is composed only of alphabets.
# Host name is started by the series name and followed by integers.
# E.g.,
#   "Fe", "Fe00", "Fe01" are of series "Fe" and not "F"
#
class MachineInfo

  class NoEntryError < Exception; end

  #
  def initialize(data)
    @data = data
  end

  def self.load_file(data_file = (ENV["HOME"] + "/.machineinfo"))
    data = YAML.load_file(data_file)
    MachineInfo.new data
  end

  def get_info(host)
    series = host.sub(/\d*$/, "")
    raise NoEntryError unless @data.has_key?(series)
    @data[series]
  end

end
