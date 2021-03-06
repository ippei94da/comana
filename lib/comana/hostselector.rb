#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

#
#
#
class Comana::HostSelector
  class NoEntryError < Exception; end

  #Argument 'groups_hosts' should be a hash;
  #the keys are group name, and the value is the hostnames of the member.
  def initialize(groups_hosts)
    @groups_hosts = groups_hosts
  end

  def self.load_file(file = Comana::ClusterSetting::DEFAULT_DATA_FILE)
    yaml = YAML.load_file(file)
    groups_hosts = {}
    yaml["groups"].each do |key, val|
      groups_hosts[key] = val["members"]
    end
    self.new(groups_hosts)
  end

  #Return all hosts included with sorted order.
  def select_all
    @groups_hosts.values.flatten.delete_if{|v| v == nil}.sort
  end

  #Return member hosts in indicated group.
  def select_group(group)
    raise NoEntryError unless @groups_hosts.keys.include? group
    @groups_hosts[group]
  end

  #Return all groups with sorted order.
  def groups
    @groups_hosts.keys.sort
  end

end

