#! /usr/bin/env ruby
# coding: utf-8

require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

#
#
#
class QueueSubmitter < ComputationManager
  QSUB_SCRIPT = "script.qsub"

  #
  def initialize(opts)
    super(opts[:d])
    @command = opts[:c]
    @nodes   = opts[:n]
    @speeed  = opts[:s]
    @machineinfo = opts[:machineinfo]
    @lockdir = "lock_queuesubmitter"
  end

  def calculate
    script_path = "#{@dir}/#{QSUB_SCRIPT}"
    File.open(script_path, "w") do |io|
      dump_qsub_str(io)
    end

    system("cd #{@dir}; qsub #{script_path} > #{@dir}/#{@lockdir}/stdout")
  end

  def prepare_next
    # do nothing
  end

  def finished?
    # do nothing
  end

  private

  def dump_qsub_str(io = nil)
    @speed 

    fs = @machineinfo.get_info("fileserver") #fileserver
    node_info = @machineinfo.get_info(@nodes)
    num = node_info["economy_mode"]
    num = node_info["speed_mode"] if @speed

    str = [
      "#! /bin/sh",
      "#PBS -N #{@dir}",
      "#PBS -l nodes=4:ppn=1:#{@nodes}",
      "#PBS -j oe",
      "mkdir -p ${PBS_O_WORKDIR}",
      "rsync -azq --delete #{fs}:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR}",
      "cd ${PBS_O_WORKDIR}",
      "#{@command}",
      "rsync -azq --delete ${PBS_O_WORKDIR}/ #{fs}:${PBS_O_WORKDIR}",
      "rm -rf ${PBS_O_WORKDIR}",
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end
end


