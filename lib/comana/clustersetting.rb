#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

# Series name is composed only of alphabets.
# Host name is started by the series name and followed by integers.
# E.g.,
#   "Fe", "Fe00", "Fe01" are of series "Fe" and not "F"
class Comana::ClusterSetting
  attr_reader :groups, :pbs_server

  class NoEntryError < Exception; end

  #
  def initialize(settings)
    @pbs_server = settings["pbs_server"]
    @groups = settings["groups"]
  end

  def self.load_file(data_file = (ENV["HOME"] + "/.clustersetting"))
    settings = YAML.load_file(data_file)
    #ClusterSetting.new settings
    self.new settings
  end

  #Return belonged cluster of the host.
  #Return nil if not match.
  def belonged_cluster(hostname)
    @groups.each do |group, settings|
      next unless settings["members"]
      return group if settings["members"].include? hostname
    end
    return nil
  end

  #Return settings as a hash for a cluster.
  def settings_group(clustername)
    @groups[clustername]
  end

  #Return settings as a hash for a host belonged to cluster.
  def settings_host(hostname)
    settings_group(belonged_cluster(hostname))
  end

  #Return an array of cluster names.
  def clusters
    @groups.keys
  end


end

