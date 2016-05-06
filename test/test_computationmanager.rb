#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "helper"
require "pp"

NOW = Time.now

class Comana::ComputationManager
  public :started?
end

class TC_ComputationManager < Test::Unit::TestCase
  class CalcYet < Comana::ComputationManager
    def finished?         ; false     ; end
  end

  class CalcStarted < Comana::ComputationManager
    def finished?         ; false     ; end
  end

  class CalcTerminated < Comana::ComputationManager
    def finished?         ; false     ; end
    def initialize(dir)
      @dir = dir
      @lockdir   = "lock_comana"
      @alive_time = 500
    end
  end

  class CalcFinished    < Comana::ComputationManager
    def finished?         ; true      ; end
  end

  class CalcNotExecutable    < Comana::ComputationManager
    def calculate
      end_status = system "" # notExistCommand
      raise ExecuteError unless end_status
    end

    def finished?
      return false
    end

    def prepare_next
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
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/lock_comana/dummy")

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
    assert_equal(:yet,        @calc00.state)
    assert_equal(:started,    @calc01.state)
    assert_equal(:yet,        @calc02.state)
    assert_equal(:terminated, @calc_terminated.state)
    assert_equal(:finished,   @calc_finished.state)
  end

  def test_latest_modified_time
    assert_equal(NOW - 1000, @calc00.latest_modified_time)
  end

  def test_started?
    assert_not_nil(@calc00.started?)
    assert_equal(false, @calc00.started?)

    assert_equal(false, @calc00.started?)
  end

  def test_start
    assert_raise(Comana::ComputationManager::ExecuteError){ @calc_not_exe.start}
  end

  def test_effective_queue
    ## 空きホストがあるときは benchmarks の短い方
    queues = ['A.q', 'B.q']
    jobs  = {'A.q' => 1, 'B.q' => 0}
    hosts = {'A.q' => 2, 'B.q' => 2}
    benchmarks = {'A.q' => 1.0, 'B.q' => 2.0}
    r = Comana::ComputationManager.effective_queue(queues, jobs, hosts, benchmarks)
    c = 'A.q'
    assert_equal(c, r)

    ## 空きホストがあるなかで選ぶ。
    queues = ['A.q', 'B.q']
    jobs  = {'A.q' => 2, 'B.q' => 0}
    hosts = {'A.q' => 2, 'B.q' => 2}
    benchmarks = {'A.q' => 1.0, 'B.q' => 2.0}
    r = Comana::ComputationManager.effective_queue(queues, jobs, hosts, benchmarks)
    c = 'B.q'
    assert_equal(c, r)

    ## 全てのホストが埋まっていたら、見込み時間の早いもので。
    queues = ['A.q', 'B.q']
    jobs  = {'A.q' => 2, 'B.q' => 2}
    hosts = {'A.q' => 2, 'B.q' => 2}
    benchmarks = {'A.q' => 1.0, 'B.q' => 2.0}
    r = Comana::ComputationManager.effective_queue(queues, jobs, hosts, benchmarks)
    c = 'A.q'
    assert_equal(c, r)

    ## 全てのホストが埋まっていたら、見込み時間の早いもので。
    queues = ['A.q', 'B.q']
    jobs  = {'A.q' => 99, 'B.q' => 2}
    hosts = {'A.q' => 2, 'B.q' => 2}
    benchmarks = {'A.q' => 1.0, 'B.q' => 2.0}
    r = Comana::ComputationManager.effective_queue(queues, jobs, hosts, benchmarks)
    c = 'B.q'
    assert_equal(c, r)
  end

  def test_guess_end_time
    assert_equal(1.0, Comana::ComputationManager.guess_end_time(0, 1, 1.0))
    assert_equal(1.0, Comana::ComputationManager.guess_end_time(1, 2, 1.0))
    assert_equal(2.0, Comana::ComputationManager.guess_end_time(1, 1, 1.0))
    assert_equal(3.0, Comana::ComputationManager.guess_end_time(2, 2, 2.0))
    assert_equal(4.5, Comana::ComputationManager.guess_end_time(8, 4, 2.0))
  end


end

