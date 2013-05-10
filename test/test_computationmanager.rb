#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "helper"

#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

NOW = Time.now

class Comana::ComputationManager
  public :latest_modified_time, :started?
end

class TC_ComputationManager < Test::Unit::TestCase
  class CalcYet < Comana::ComputationManager
    def finished?         ; false     ; end
  end

  class CalcStarted < Comana::ComputationManager
    def finished?         ; false     ; end
  end

  #describe Comana::ComputationManager, "with output, without lock" do
  class CalcStarted < Comana::ComputationManager
    def finished?         ; false     ; end
  end

  #describe Comana::ComputationManager, "terminated" do
  class CalcTerminated < Comana::ComputationManager
    def finished?         ; false     ; end
    def initialize(dir)
      @dir = dir
      @lockdir   = "lock_comana"
      @alive_time = 500
    end
  end

  #describe Comana::ComputationManager, "finished" do
  class CalcFinished    < Comana::ComputationManager
    def finished?         ; true      ; end
  end

  #describe Comana::ComputationManager, "cannot execute" do
  class CalcNotExecutable    < Comana::ComputationManager
    def calculate
      end_status = system "" # notExistCommand
      raise ExecuteError unless end_status
    end

    def finished?
      return false
    end

    def prepare_next
      #return false
      raise
    end
  end




  def setup
    calc_dir = "test/not_started"
    @calc00 = CalcYet.new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    @lockdir = "#{calc_dir}/lock_comana"
    FileUtils.rm(@lockdir) if File.exist?(@lockdir)


    calc_dir = "test/locked"
    @calc01 = CalcStarted   .new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")

    calc_dir = "test/outputted"
    @calc02 = CalcStarted   .new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/output")

    calc_dir = "test/locked_outputted"
    @calc_terminated   = CalcTerminated.new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/output")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/lock_comana")

    calc_dir = "test/locked_outputted"
    @calc_finished     = CalcFinished  .new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")

    calc_dir = "test/not_executable"
    @calc_not_exe     = CalcNotExecutable  .new(calc_dir)
    @lockdir = calc_dir + "/lock_comana"
    Dir.rmdir(@lockdir) if File.exist?(@lockdir)
  end

  def test_state
    assert_equal(:yet,     @calc00.state)
    assert_equal(:started, @calc01.state)
    assert_equal(:yet,     @calc02.state)
    assert_equal(:terminated, @calc_terminated.state)
    assert_equal(:finished, @calc_finished.state)
  end

  def test_latest_modified_time
    #it "should return latest modified time" do
    assert_equal(NOW - 1000, @calc00.latest_modified_time)
  end

  def test_started?
    #it "should return false without lock." do
    assert_not_nil(@calc00.started?)
    assert_equal(false, @calc00.started?)

    #it "should return true with lock." do
    assert_equal(false, @calc00.started?)
  end

  def test_start
    #it "should raise error" do
    assert_raise(Comana::ComputationManager::ExecuteError){ @calc_not_exe.start}
  end
end

