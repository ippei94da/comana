#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

# Series name is composed only of alphabets.
# Host name is started by the series name and followed by integers.
# E.g.,
#   "Fe", "Fe00", "Fe01" are of series "Fe" and not "F"
#
# MEMO: This class should be renamed to be "MachineSetting"?
class Comana::MachineInfo
  attr_reader :groups_settings

  class NoEntryError < Exception; end

  #
  def initialize(groups_settings)
    @groups_settings = groups_settings
  end

  def self.load_file(data_file = (ENV["HOME"] + "/.machineinfo"))
    groups_settings = YAML.load_file(data_file)
    #MachineInfo.new groups_settings
    self.new groups_settings
  end

  def get_info(host)
    series = host.sub(/\d*$/, "")
    unless @groups_settings.has_key?(series)
      raise NoEntryError,
        "#{series}"
    end
    @groups_settings[series]
  end

  #def has_info?(host)
  #  series = host.sub(/\d*$/, "")
  #  unless @groups_settings.has_key?(series)
  #    raise NoEntryError,
  #      "#{series}"
  #  end
  #  @groups_settings[series]
  #end

end

