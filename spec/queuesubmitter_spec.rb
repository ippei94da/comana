#! /usr/bin/env ruby
# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/queuesubmitter.rb"
require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

class QueueSubmitter < ComputationManager
  public :dump_prologue
  public :dump_script
  public :dump_epilogue
end

#describe QueueSubmitter, "with chars to be escaped" do
describe QueueSubmitter do
  describe "#initialize" do
    context "opts not have target" do
      opts = {
        #"target" => "dir_name",
        "command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :command" do
      opts = {
        "target" => ComputationManager.new("dir_name"),
        #"command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have cluster" do
      opts = {
        "target" => ComputationManager.new("dir_name"),
        "command" => "command_line",
        #"cluster" => "Nodes",
        "number"  => 4,
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :command" do
      opts = {
        "target" => ComputationManager.new("dir_name"),
        #"command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end
  end

  #describe "#self.correct_options" do
  #  before do
  #    @machine_info = MachineInfo.new(
  #      {
  #        "CLUSTER" => {
  #          "speed" => 2,
  #          "economy" => 1,
  #          "command" => "calc_command"
  #        },
  #      }
  #    )
  #  end

  #  context "cluster not indicated" do
  #    opts = {
  #      "number" => 1,
  #      #"cluster" => "CLUSTER",
  #      "target" => "calc_dir",
  #    }
  #    it {lambda{QueueSubmitter.correct_options(opts, @machine_info)}.should
  #      raise_error(QueueSubmitter::InvalidArgumentError)}
  #  end

  #  context "target not indicated" do
  #    opts = {
  #      "number" => 1,
  #      "cluster" => "CLUSTER",
  #      #"target" => "calc_dir",
  #    }
  #    it {lambda{QueueSubmitter.correct_options(opts, @machine_info)}.should
  #      raise_error(QueueSubmitter::InvalidArgumentError)}
  #  end

  #  context "number not indicated" do
  #    opts = {
  #      #"number" => 1,
  #      "cluster" => "CLUSTER",
  #      "target" => "calc_dir",
  #    }
  #    it {lambda{QueueSubmitter.correct_options(opts, @machine_info)}.should
  #      raise_error(QueueSubmitter::InvalidArgumentError)}
  #  end

  #  context "orthodox indication" do
  #    opts = {
  #      "number" => 1,
  #      "cluster" => "CLUSTER",
  #      "target" => "calc_dir",
  #    }
  #    results = QueueSubmitter.correct_options(opts, @machine_info)
  #    it {results.should == 
  #      {
  #        "target"  => "calc_dir",
  #        "command" => "calc_command",
  #        "number"  => 1,
  #        "cluster" => "CLUSTER",
  #      }
  #    }
  #  end

  #  context "number indication as string in MachineInfo" do
  #    opts = {
  #      "cluster" => "CLUSTER",
  #      "number" => "speed",
  #      "target" => "calc_dir",
  #    }
  #    results = QueueSubmitter.correct_options(opts, @machine_info)
  #    it {results.should == 
  #      {
  #        "cluster" => "CLUSTER",
  #        "number"  => 2,
  #        "target"  => "calc_dir",
  #        "command" => "calc_command",
  #      }
  #    }
  #  end
  #end

  describe "#dump_prologue" do
    before do
      opts = {
        "target" => ComputationManager.new("spec/not_started"),
        "command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      @qs00 = QueueSubmitter.new(opts)

      @correct = [
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
    end

    context "speed mode" do
      it { @qs00.dump_prologue.should == @correct}
    end
  end

  describe "#dump_script" do
    before do
      opts = {
        "target" => ComputationManager.new("spec/not_started"),
        "command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      @qs00 = QueueSubmitter.new(opts)

      @correct = [
        "#! /bin/sh",
        "#PBS -N spec/not_started",
        "#PBS -l nodes=4:ppn=1:Nodes,walltime=7:00:00:00",
        "#PBS -j oe",
        "",
        "cd ${PBS_O_WORKDIR} && \\",
        "command_line",
      ].join("\n")
    end

    context "speed mode" do
      it { @qs00.dump_script.should == @correct}
    end
  end

  describe "#dump_epilogue" do
    before do
      opts = {
        "target" => ComputationManager.new("spec/not_started"),
        "command" => "command_line",
        "cluster" => "Nodes",
        "number"  => 4,
      }
      @qs00 = QueueSubmitter.new(opts)

      @correct = [
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
    end

    context "speed mode" do
      it { @qs00.dump_epilogue.should == @correct}
    end
  end



  describe "#finished?" do
    context "locked" do
      it do
        opts = {
          "target" => ComputationManager.new("spec/queuesubmitter/locked"),
          "command" => "command_line",
          "cluster" => "Nodes",
          "number"  => 4,
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == true
      end
    end

    context "unlocked" do
      it do
        opts = {
          "target" => ComputationManager.new("spec/queuesubmitter/unlocked"),
          "command" => "command_line",
          "cluster" => "Nodes",
          "number"  => 4,
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == false
      end
    end
  end
end
