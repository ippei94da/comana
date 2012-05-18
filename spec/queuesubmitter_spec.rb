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
    context "opts not have :directory" do
      opts = {
        #:directory => "dir_name",
        :command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :command" do
      opts = {
        :directory => ComputationManager.new("dir_name"),
        #:command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :cluster" do
      opts = {
        :directory => ComputationManager.new("dir_name"),
        :command => "command_line",
        #:cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :command" do
      opts = {
        :directory => ComputationManager.new("dir_name"),
        #:command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end
  end

  describe "#self.parse_options" do
    before do
      @machine_info = MachineInfo.new(
        {
          "fileserver" => "FS",
          "CLUSTER" => {
            "speed" => 2,
            "economy" => 1,
          },
        }
      )
    end

    context "-c not indicated" do
      ary = %w( a -n 1 )
      it {lambda{QueueSubmitter.parse_options(ary, @machine_info)}.should raise_error(
        QueueSubmitter::InvalidArgumentError)}
    end

    #context "-n not indicated" do
    #  ary = %w( a -c CLUSTER_DUMMY )
    #  it {lambda{QueueSubmitter.parse_options(ary, @machine_info)}.should raise_error(MachineInfo::NoEntryError)}
    #end

    context "-n not indicated" do
      ary = %w( a -c CLUSTER )
      it {lambda{QueueSubmitter.parse_options(ary, @machine_info)}.should raise_error(QueueSubmitter::InvalidArgumentError)}
    end

    context "-c and -n number indicated" do
      ary = %w( a -c CLUSTER -n 1 )
      it {lambda{QueueSubmitter.parse_options(ary, @machine_info)}.should_not raise_error}
    end

  end

  describe "#dump_prologue" do
    before do
      opts = {
        :directory => ComputationManager.new("spec/not_started"),
        :command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
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
        :directory => ComputationManager.new("spec/not_started"),
        :command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
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
        :directory => ComputationManager.new("spec/not_started"),
        :command => "command_line",
        :cluster => "Nodes",
        :number  => 4,
        :fileserver => "FS",
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
          :directory => ComputationManager.new("spec/queuesubmitter/locked"),
          :command => "command_line",
          :cluster => "Nodes",
          :number  => 4,
          :fileserver => "FS",
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == true
      end
    end

    context "unlocked" do
      it do
        opts = {
          :directory => ComputationManager.new("spec/queuesubmitter/unlocked"),
          :command => "command_line",
          :cluster => "Nodes",
          :number  => 4,
          :fileserver => "FS",
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == false
      end
    end
  end
end
