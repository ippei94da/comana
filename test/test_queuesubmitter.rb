#! /usr/bin/env ruby
# coding: utf-8

require "helper"
class Comana::QueueSubmitter # < ComputationManager
  public :dump_prologue
  public :dump_script
  public :dump_epilogue
end

class TC_QueueSubmitter < Test::Unit::TestCase
  def setup
    opts = {
      :target => Comana::ComputationManager.new("test/not_started"),
      :command => "command_line",
      :cluster => "Nodes",
      :num_nodes  => 4,
    }
    @qs_notstarted = Comana::QueueSubmitter.new(opts)

    opts = {
      :target => Comana::ComputationManager.new("test/queuesubmitter/locked"),
      :command => "command_line",
      :cluster => "Nodes",
      :num_nodes  => 4,
    }
    @qs_locked = Comana::QueueSubmitter.new(opts)

    opts = {
      :target => Comana::ComputationManager.new("test/queuesubmitter/unlocked"),
      :command => "command_line",
      :cluster => "Nodes",
      :num_nodes  => 4,
    }
    @qs_unlocked = Comana::QueueSubmitter.new(opts)
  end

  def test_initialize
    opts = {
      #:target => "dir_name",
      :command => "command_line",
      :cluster => "Nodes",
      :num_nodes  => 4,
    }
    assert_raise(Comana::QueueSubmitter::InitializeError){
      Comana::QueueSubmitter.new(opts)
    }

    opts = {
      :target => Comana::ComputationManager.new("dir_name"),
      #:command => "command_line",
      :cluster => "Nodes",
      :num_nodes  => 4,
    }
    assert_raise(Comana::QueueSubmitter::InitializeError){
      Comana::QueueSubmitter.new(opts)
    }

    opts = {
      :target => Comana::ComputationManager.new("dir_name"),
      :command => "command_line",
      #:cluster => "Nodes",
      :num_nodes  => 4,
    }
    assert_nothing_raised{ Comana::QueueSubmitter.new(opts) }

    opts = {
      :target => Comana::ComputationManager.new("dir_name"),
      :command => "command_line",
      :cluster => "Nodes",
      #:num_nodes  => 4,
    }
    assert_nothing_raised{ Comana::QueueSubmitter.new(opts) }
  end

  def test_dump_prologue
    #context "speed mode" do
    correct = [
      '#! /bin/sh',
      'LOGFILE="${PBS_O_WORKDIR}/prologue_script.log"',
      'echo "hostname                         : `hostname`" >> $LOGFILE',
      'echo "job id                           : $1" >> $LOGFILE',
      'echo "job execution user name          : $2" >> $LOGFILE',
      'echo "job execution group name         : $3" >> $LOGFILE',
      'echo "job name                         : $4" >> $LOGFILE',
      'echo "list of requested resource limits: $5" >> $LOGFILE',
      'echo "job execution queue              : $6" >> $LOGFILE',
      'echo "job account                      : $7" >> $LOGFILE',
      'echo "PBS_O_WORKDIR                    : ${PBS_O_WORKDIR}" >> $LOGFILE',
      'echo "nodes in pbs_nodefile            : " >> $LOGFILE',
      'cat ${PBS_NODEFILE} >> $LOGFILE',
      'exit 0',
    ].join("\n")
    assert_equal(correct, @qs_notstarted.dump_prologue)
  end

  def test_dump_script
    correct = [
      "#! /bin/sh",
      "#PBS -N test/not_started",
      "#PBS -l nodes=4:ppn=1:Nodes,walltime=7:00:00:00",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "command_line",
    ].join("\n")
    assert_equal(correct, @qs_notstarted.dump_script)


    opts = {
      :target => Comana::ComputationManager.new("test/not_started"),
      :command => "command_line",
      #:cluster => "Nodes",
      :num_nodes  => 4,
    }
    qs = Comana::QueueSubmitter.new(opts)
    correct = [
      "#! /bin/sh",
      "#PBS -N test/not_started",
      "#PBS -l nodes=4:ppn=1,walltime=7:00:00:00",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "command_line",
    ].join("\n")
    assert_equal(correct, qs.dump_script)


    opts = {
      :target => Comana::ComputationManager.new("test/not_started"),
      :command => "command_line",
      :cluster => "Nodes",
      #:num_nodes  => 4,
    }
    qs = Comana::QueueSubmitter.new(opts)
    correct = [
      "#! /bin/sh",
      "#PBS -N test/not_started",
      "#PBS -l nodes=1:ppn=1:Nodes,walltime=7:00:00:00",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "command_line",
    ].join("\n")
    assert_equal(correct, qs.dump_script)

    opts = {
      :target => Comana::ComputationManager.new("test/not_started"),
      :command => "command_line",
      #:cluster => "Nodes",
      #:num_nodes  => 4,
    }
    qs = Comana::QueueSubmitter.new(opts)
    correct = [
      "#! /bin/sh",
      "#PBS -N test/not_started",
      "#PBS -l walltime=7:00:00:00",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "command_line",
    ].join("\n")
    assert_equal(correct, qs.dump_script)

    opts = {
      :target => Comana::ComputationManager.new("test/not_started"),
      :command => "command_line",
      #:cluster => "Nodes",
      #:num_nodes  => 4,
      :priority => -10,
    }
    qs = Comana::QueueSubmitter.new(opts)
    correct = [
      "#! /bin/sh",
      "#PBS -N test/not_started",
      "#PBS -l walltime=7:00:00:00",
      "#PBS -p -10",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "command_line",
    ].join("\n")
    assert_equal(correct, qs.dump_script)

  end

  def test_dump_epilogue
    correct = [
      '#! /bin/sh',
      'LOGFILE="${PBS_O_WORKDIR}/epilogue_script.log"',
      'echo "job id                           : $1" >> $LOGFILE',
      'echo "job execution user name          : $2" >> $LOGFILE',
      'echo "job execution group name         : $3" >> $LOGFILE',
      'echo "job name                         : $4" >> $LOGFILE',
      'echo "session id                       : $5" >> $LOGFILE',
      'echo "list of requested resource limits: $6" >> $LOGFILE',
      'echo "list of resources used by job    : $7" >> $LOGFILE',
      'echo "job execution queue              : $8" >> $LOGFILE',
      'echo "job account                      : $9" >> $LOGFILE',
      'echo "job exit code                    : $10" >> $LOGFILE',
      'exit 0',
    ].join("\n")

    assert_equal(correct, @qs_notstarted.dump_epilogue)
  end

  def test_finished?
    #context "locked" do
    assert_equal(true, @qs_locked.finished?)

    #context "unlocked" do
    assert_equal(false, @qs_unlocked.finished?)
  end
end
