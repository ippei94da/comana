#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

# Series name is composed only of alphabets.
# Host name is started by the series name and followed by integers.
# E.g.,
#   "Fe", "Fe00", "Fe01" are of series "Fe" and not "F"
class Comana::ClusterSetting
  attr_reader :data_file, :groups, :pbs_server

  DEFAULT_DATA_FILE = ENV["HOME"] + "/.clustersetting"

  class NoEntryError < Exception; end

  #
  def initialize(settings, data_file = nil)
    @pbs_server = settings["pbs_server"]
    @groups = settings["groups"]
    @data_file = data_file
  end

  def self.load_file(data_file = DEFAULT_DATA_FILE)
    settings = YAML.load_file(data_file)
    self.new(settings, data_file)
  end

  #Return belonged cluster of the host.
  #Raise NoEntryError if not match.
  def belonged_cluster(hostname)
    @groups.each do |group, settings|
      next unless settings["members"]
      return group if settings["members"].include? hostname
    end
    raise NoEntryError, "#{hostname} is not in `@groups': #{@groups.inspect}"
  end

  #Return settings as a hash for a cluster.
  def settings_group(clustername)
    @groups[clustername]
  end

  #Return settings as a hash for a cluster, the 'queue' key has a value of q_name.
  def settings_queue(q_name)
    result = nil
    #pp @groups
    @groups.each do |name, items|
      result = items if items['queue'] == q_name
    end
    result
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

