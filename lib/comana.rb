#! /usr/bin/env ruby
# coding: utf-8

#
# Comana: COmputation MANAger
#
# This profides a framework of scientific computation.
# Users have to redefine some methods in subclasses for various computation.
# 
class Comana
  class NotImplementedError < Exception; end
  class AlreadyStartedError < Exception; end

  attr_reader :dir

  #
  def initialize(dir)
    @dir = dir
    set_parameters
  end

  # Return a symbol which indicate state of calculation.
  #   :yet           not started
  #   :started       started, but not ended, including short time from last output
  #   :terminated    started, but long time no output
  #   :finished      started, normal ended and not need next calculation
  def state
    return :finished   if finished?
    return :yet        unless started?
    return :terminated if (Time.now - latest_modified_time > @alive_time)
    return :started    
  end

  # Execute calculation.
  # If log of Comana exist, raise Comana::AlreadyStartedError,
  # because the calculation has been done by other process already.
  def calculate
    begin
      Dir.mkdir "#{@dir}/#{@lockdir}"
    rescue Errno::EEXIST
      raise AlreadyStartedError, "Exist #{@dir}/#{@lockdir}"
    end
    send_command
  end

  private

  def send_command
    raise NotImplementedError, "#{self.class}::send_command need to be redefined"
  end

  def set_parameters
    raise NotImplementedError, "#{self.class}::set_parameters need to be redefined"

    # e.g.,
    #@lockdir    = "comana_lock"
    #@alive_time = 3600
    #@outfiles   = ["output_a", "ouput_b"] # Files only to output should be indicated.
  end

  # Return latest modified time of files in calc dir recursively.
  # require "find"
  # Not only @outfiles, to catch an irregular state at the beginning before output.
  def latest_modified_time
    tmp = Dir.glob("#{@dir}/**/*").max_by do |file|
      File.mtime(file)
    end
    File.mtime(tmp)
  end

  def started?
    return true if File.exist?( "#{@dir}/#{@lockdir}" )
    #@outfiles.each do |file|
    #  return true if File.exist?( "#{@dir}/#{file}" )
    #end
    return false
  end

  # Return true if the condition is satisfied.
  # E.g., when calculation output contains orthodox ending sequences.
  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

