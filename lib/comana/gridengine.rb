#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class GridEngine

  def self.write_qsub_script(q_name:, pe_name:, ppn:, ld_library_path: , command:, io:)
    io.puts "#! /bin/sh"
    io.puts "#$ -S /bin/sh"
    io.puts "#$ -cwd"
    io.puts "#$ -o stdout"
    io.puts "#$ -e stderr"
    io.puts "#$ -q #{q_name}"
    io.puts "#$ -pe #{pe_name} #{ppn}"
    io.puts "MACHINE_FILE='machines'"
    io.puts "LD_LIBRARY_PATH=#{ld_library_path}"
    io.puts "export LD_LIBRARY_PATH"
    io.puts "cd $SGE_O_WORKDIR"
    io.puts "printenv | sort > printenv.log"
    io.puts "cut -d ' ' -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE"
    io.puts "#{command}"
    #{__FILE__} execute
  end

#  #DEFAULT_QSUB_FILE = 'qsub.sh'
#  QSUB_PATH = '/usr/bin/qsub'
#
#  #
#  def initialize()
#  end
#
#  # series: name of computers' series
#  # ppn:    number of using cores
#  def self.generate(io, series, ppn, command)
#    io.puts self.string(series, ppn, command)
#  end
#
#  def self.string(series, ppn, command)
#    string = <<HERE
#\#! /bin/sh
#\#$ -S /bin/sh
#\#$ -cwd
#\#$ -o stdout
#\#$ -e stderr
#\#$ -q #{series}.q
#\#$ -pe #{series}.openmpi #{ppn}
#
#MACHINE_FILE="machines"
#ENV_FILE="printenv.log"
#
#LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/opt/intel/mkl/lib/intel64:/opt/intel/lib/intel64:/opt/intel/lib:/opt/openmpi-intel/lib
#export LD_LIBRARY_PATH
#
#cd $SGE_O_WORKDIR
#if [ -e $ENV_FILE ]; then
#    echo "$ENV_FILE already exist. Exit."
#    exit
#fi
#printenv | sort > printenv.log
#cut -d " " -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE
#
##{command}
#HERE
#    string
#  end
#
#  def self.write(series, ppn, command, io)
#    io.puts self.string(series, ppn, command)
#  end
#
#  def self.write_submit(series, ppn, command, filename)
#    #qsub_file = DEFAULT_QSUB_FILE
#    io = File.open(filename, 'w')
#    self.write(series, ppn, command, io)
#    io.close
#
#    logfile  = filename.sub(/#{File.extname filename}$/, '.log')
#    command = "#{QSUB_PATH} #{filename} > #{logfile}"
#    #command = "qsub #{filename}"
#    puts command
#    system command
#  end

end


