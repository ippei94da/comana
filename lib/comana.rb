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

  #
  def initialize(dir)
    @dir = dir
    set_parameters
  end

  # Return a symbol which indicate state of calculation.
  #   :yet           not started
  #   :started       started, but not ended, including short time from last output
  #   :terminated    started, but long time no output
  #   :next          started, normal ended and need next calculation
  #   :finished      started, normal ended and not need next calculation
  def state
    return :finished   if finished?
    return :next       if normal_ended?
    return :yet        unless started?
    return :terminated if (Time.now - latest_modified_time > @alive_time)
    return :started    
  end

  # Execute calculation.
  # If log of Comana exist, raise Comana::AlreadyStartedError,
  # because the calculation has been done by other process already.
  def calculate
    raise AlreadyStartedError if started?
    File.open(@log, "w")
    send_command
  end

  # Generate next calculation and return the computation object.
  def prepare_next
    raise NotImplementedError, "#{self.class}::prepare_next need to be redefined"
  end

  # Return initial state.
  def initial_state
    raise NotImplementedError, "#{self.class}::initial_state need to be redefined"
  end

  # Return latest state.
  def latest_state
    raise NotImplementedError, "#{self.class}::latest_state need to be redefined"
  end

  private

  def send_command
    raise NotImplementedError, "#{self.class}::send_command need to be redefined"
  end

  def set_parameters
    raise NotImplementedError, "#{self.class}::set_parameters need to be redefined"

    # e.g.,
    #@logfile    = "comana.log"
    #@alive_time = 3600
    #@outfiles   = ["output_a", "ouput_b"] # should be use files only to output.
  end

  # Return latest modified time of files in calc dir recursively.
  #require "find"
  def latest_modified_time
    tmp = Dir.glob("#{@dir}/**/*").max_by do |file|
      File.mtime(file)
    end
    File.mtime(tmp)
  end

  def started?
    File.exist?( "#{@dir}/#{@logfile}" )
  end

  # Return true if the condition is satisfied.
  # E.g., when calculation output contains orthodox ending sequences.
  def normal_ended?
    raise NotImplementedError, "#{self.class}::normal_ended? need to be redefined"
  end

  # Return true if the condition is satisfied.
  # E.g., calculation achieve convergence.
  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

