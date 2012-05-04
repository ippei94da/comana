#! /usr/bin/env ruby
# coding: utf-8

require "yaml"

#
#
#
class Machineinfo
  #
  def initialize(data_file)
    @data = YAML.load_file(data_file)
  end

end

