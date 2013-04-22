#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

# Series name is composed only of alphabets.
# Host name is started by the series name and followed by integers.
# E.g.,
#   "Fe", "Fe00", "Fe01" are of series "Fe" and not "F"
class Comana::ClusterSetting
  attr_reader :groups_settings

  class NoEntryError < Exception; end

  #
  def initialize(groups_settings)
    @groups_settings = groups_settings
  end

  def self.load_file(data_file = (ENV["HOME"] + "/.clustersetting"))
    groups_settings = YAML.load_file(data_file)
    #ClusterSetting.new groups_settings
    self.new groups_settings
  end

  #Return belonged cluster of the host.
  #Return nil if not match.
  def belonged_cluster(hostname)
    @groups_settings.each do |group, settings|
      return group if settings["members"].include? hostname
    end
    return nil
  end

  #Return settings as a hash for a cluster.
  def settings_group(clustername)
    @groups_settings[clustername]
  end

  #Return settings as a hash for a host belonged to cluster.
  def settings_host(hostname)
    settings_group(belonged_cluster(hostname))
  end

  #Return an array of cluster names.
  def clusters
    @groups_settings.keys
  end


  #def get_info(host)
  #  series = host.sub(/\d*$/, "")
  #  unless @groups_settings.has_key?(series)
  #    raise NoEntryError,
  #      "#{series}"
  #  end
  #  @groups_settings[series]
  #end

  #def has_info?(host)
  #  series = host.sub(/\d*$/, "")
  #  unless @groups_settings.has_key?(series)
  #    raise NoEntryError,
  #      "#{series}"
  #  end
  #  @groups_settings[series]
  #end

end

