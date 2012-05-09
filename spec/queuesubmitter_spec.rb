#! /usr/bin/env ruby
# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/queuesubmitter.rb"
require "comana/machineinfo.rb"

class QueueSubmitter < ComputationManager
  public :dump_qsub_str
end

#describe QueueSubmitter, "with chars to be escaped" do
describe QueueSubmitter do
  describe "#initialize" do
    context "opts not have :d" do
      opts = {
        #:d => "dir_name",
        :c => "command_line",
        :n => "Nodes",
        :s => true,
        :machineinfo => MachineInfo.new(
          "fileserver" => "FS",
          "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
        )
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :c" do
      opts = {
        :d => "dir_name",
        #:c => "command_line",
        :n => "Nodes",
        :s => true,
        :machineinfo => MachineInfo.new(
          "fileserver" => "FS",
          "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
        )
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :n" do
      opts = {
        :d => "dir_name",
        :c => "command_line",
        #:n => "Nodes",
        :s => true,
        :machineinfo => MachineInfo.new(
          "fileserver" => "FS",
          "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
        )
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end

    context "opts not have :c" do
      opts = {
        :d => "dir_name",
        :c => "command_line",
        :n => "Nodes",
        :s => true,
        #:machineinfo => MachineInfo.new(
        #  "fileserver" => "FS",
        #  "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
        #)
      }
      it {lambda{QueueSubmitter.new(opts)}.should raise_error(
        QueueSubmitter::InitializeError)}
    end
  end

  describe "#dump_qsub_str" do
    before do
      opts = {
        :d => ComputationManager.new("spec/not_started"),
        :c => "command_line",
        :n => "Nodes",
        :s => true,
        :machineinfo => MachineInfo.new(
          "fileserver" => "FS",
          "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
        )
      }
      @qs00 = QueueSubmitter.new(opts)

      @correct = [
        "#! /bin/sh",
        "#PBS -N spec/not_started",
        "#PBS -l nodes=4:ppn=1:Nodes,walltime=7:00:00:00",
        "#PBS -j oe",
        "mkdir -p ${PBS_O_WORKDIR}",
        "cp ${PBS_NODEFILE} ${PBS_O_WORKDIR}/pbs_nodefile",
        "rsync -azq --delete FS:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR}",
        "cd ${PBS_O_WORKDIR}",
        "command_line",
        "rsync -azq --delete ${PBS_O_WORKDIR}/ FS:${PBS_O_WORKDIR}",
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
          :d => ComputationManager.new("spec/queuesubmitter/locked"),
          :c => "command_line",
          :n => "Nodes",
          :s => true,
          :machineinfo => MachineInfo.new(
            "fileserver" => "FS",
            "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
          )
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == true
      end
    end

    context "unlocked" do
      it do
        opts = {
          :d => ComputationManager.new("spec/queuesubmitter/unlocked"),
          :c => "command_line",
          :n => "Nodes",
          :s => true,
          :machineinfo => MachineInfo.new(
            "fileserver" => "FS",
            "Nodes" => { "speed_nodes" => 4, "economy_nodes" => 1, }
          )
        }
        @qs00 = QueueSubmitter.new(opts)

        @qs00.finished?.should == false
      end
    end
  end
end
