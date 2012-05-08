#! /usr/bin/env ruby
# coding: utf-8

require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

#
#
#
class QueueSubmitter < ComputationManager
  QSUB_SCRIPT = "script.qsub"

  class PrepareNextError < Exception; end

  # opts is a hash includes data belows:
  #   :d => calculation as comana subclass.
  #   :c => command line
  #   :n => 
  #   :s => 
  #   :machineinfo => 
  def initialize(opts)
    super(opts[:d].dir)
    @command = opts[:c]
    @nodes   = opts[:n]
    @speed  = opts[:s]
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

  # Raise QueueSubmitter::PrepareNextError when called.
  def prepare_next
    raise PrepareNextError
  end

  def finished?
    # do nothing
  end

  private

  def dump_qsub_str(io = nil)
    fs = @machineinfo.get_info("fileserver") #fileserver
    node_info = @machineinfo.get_info(@nodes)
    num = node_info["economy_nodes"]
    num = node_info["speed_nodes"] if @speed

    str = [
      "#! /bin/sh",
      "#PBS -N #{@dir}",
      "#PBS -l nodes=#{num}:ppn=1:#{@nodes},walltime=168:00:00",
      "#PBS -j oe",
      "mkdir -p ${PBS_O_WORKDIR}",
      "cp ${PBS_NODEFILE} ${PBS_O_WORKDIR}/pbs_nodefile",
      "rsync -azq --delete #{fs}:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR}",
      "cd ${PBS_O_WORKDIR}",
      "#{@command}",
      "#rsync -azq --delete ${PBS_O_WORKDIR}/ #{fs}:${PBS_O_WORKDIR}",
      "#rm -rf ${PBS_O_WORKDIR}",
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end
end


