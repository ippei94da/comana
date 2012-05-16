#! /usr/bin/env ruby
# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/queuesubmitter.rb"
require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

class QueueSubmitter < ComputationManager
  public :dump_qsub_str
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

  describe "#dump_qsub_str" do
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
        "mkdir -p ${PBS_O_WORKDIR} && \\",
        "rsync -azq --delete FS:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR} && \\",
        "cp ${PBS_NODEFILE} ${PBS_O_WORKDIR}/pbs_nodefile && \\",
        "cd ${PBS_O_WORKDIR} && \\",
        "command_line && \\",
        "rsync -azq --delete ${PBS_O_WORKDIR}/ FS:${PBS_O_WORKDIR} && \\",
        "#rm -rf ${PBS_O_WORKDIR}",
        "mv ${PBS_O_WORKDIR} ~/.trash",
      ].join("\n")
    end

    context "speed mode" do
      it { @qs00.dump_qsub_str.should == @correct}

      it do
        io = StringIO.new
        @qs00.dump_qsub_str(io)
        io.rewind
        #pp io.readlines
        io.readlines.join.chomp.should == @correct
      end
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
