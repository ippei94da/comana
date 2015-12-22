#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class GridEngineScript
  #
  def initialize()
  end

  # series: name of computers' series
  # ppn:    number of using cores
  def self.generate(io, series, ppn, command)
    io.puts self.string(series, ppn, command)
  end

  def self.string(series, ppn, command)
    string = <<HERE
\#! /bin/sh
\#$ -S /bin/sh
\#$ -cwd
\#$ -o stdout
\#$ -e stderr
\#$ -q #{series}.q
\#$ -pe #{series}.openmpi #{ppn}

MACHINE_FILE="machines"
ENV_FILE="printenv.log"

LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/opt/intel/mkl/lib/intel64:/opt/intel/lib/intel64:/opt/intel/lib:/opt/openmpi-intel/lib
export LD_LIBRARY_PATH

cd $SGE_O_WORKDIR
if [ -e $ENV_FILE ]; then
    echo "$ENV_FILE already exist. Exit."
    exit
fi
printenv | sort > printenv.log
cut -d " " -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE

#{command}
HERE
  end

end

