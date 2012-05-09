#! /usr/bin/env ruby
# coding: utf-8

# This class profides a framework of scientific computation.
# Users have to redefine some methods in subclasses for various computation.
# 
class ComputationManager
  class NotImplementedError < Exception; end
  class AlreadyStartedError < Exception; end
  class ExecuteError < Exception; end

  attr_reader :dir

  # You can redefine in subclass to modify from default values.
  def initialize(dir)
    @dir = dir # redefine in subclass. 
    @lockdir    = "lock_comana"
    @alive_time = 3600
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
  # If log of ComputationManager exist, raise ComputationManager::AlreadyStartedError,
  # because the calculation has been done by other process already.
  def start
    begin
      Dir.mkdir "#{@dir}/#{@lockdir}"
    rescue Errno::EEXIST
      raise AlreadyStartedError, "Exist #{@dir}/#{@lockdir}"
    end

    while true
      calculate
      break if finished?
      prepare_next
    end
    puts "Done."
  end

  private

  # Redefine in subclass, e.g., 
  #   end_status = system "command"
  #   raise ExecuteError unless end_status
  def calculate
    raise NotImplementedError, "#{self.class}::calculate need to be redefined"
  end

  def prepare_next
    raise NotImplementedError, "#{self.class}::prepare_next need to be redefined"
  end

  # Return latest modified time of files in calc dir recursively.
  # require "find"
  def latest_modified_time
    tmp = Dir.glob("#{@dir}/**/*").max_by do |file|
      File.mtime(file)
    end
    File.mtime(tmp)
  end

  def started?
    return true if File.exist?( "#{@dir}/#{@lockdir}" )
    return false
  end

  # Return true if the condition is satisfied.
  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

