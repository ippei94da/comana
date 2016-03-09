#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class Comana::GridEngine

  def self.write_qsub_script(q_name:, pe_name:, ppn:, ld_library_path: , command:, io:)
    io.puts "#! /bin/sh"
    io.puts "#$ -S /bin/sh"
    io.puts "#$ -cwd"
    io.puts "#$ -o stdout"
    io.puts "#$ -e stderr"
    io.puts "#$ -q #{q_name}"
    io.puts "#$ -pe #{pe_name} #{ppn}"
    io.puts "MACHINE_FILE='machines'"
    io.puts "LD_LIBRARY_PATH=#{ld_library_path}" if ld_library_path
    io.puts "export LD_LIBRARY_PATH" if ld_library_path
    io.puts "cd $SGE_O_WORKDIR"
    io.puts "printenv | sort > printenv.log"
    io.puts "cut -d ' ' -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE"
    io.puts "#{command}"
    #{__FILE__} execute
  end

  def self.qstat_f(io = IO.popen("qstat -f -xml", "r+"))
    qs = Nokogiri::XML(io)
    results = qs.xpath("/job_info/queue_info/Queue-List").map do |queue|
      hash = {}
      queue.children.each do |j|
        next if j.name == 'text'
        key = j.name
        val = j.children.to_s
        val = val.to_i if val.integer?
        hash[key] = val
      end
      hash
    end
    results
  end

  def self.queue_alive_hosts(io = IO.popen("qstat -f -xml", "r+"))
    qs = self.qstat_f(io)
    results = {}
    qs.each do |q|
      next if q['state'] == 'au'
      /(.*)\@(.*)/ =~ q["name"]
      q = $1
      host = $2
      results[q] ||= []
      results[q] << host
    end
    results
  end

  def self.queue_alive_nums(io = IO.popen("qstat -f -xml", "r+"))
    qs = self.queue_alive_hosts(io)
    results = {}
    qs.each do |key,val|
      results[key] = val.size
    end
    results
  end

  def self.qstat_u(io = IO.popen("qstat -u '*' -xml", "r+"))
    qs = Nokogiri::XML(io)
    results = []
    qs.xpath("/job_info/queue_info/job_list").each do |queue|
      hash = {}
      value = queue.attributes.values[0].to_s
      hash['job_list_state'] = value
      queue.children.each do |j|
        next if j.name == 'text'
        key = j.name
        val = j.children.to_s
        if val.integer?
          val = val.to_i
        elsif val.float?
          val = val.to_f
        end
        hash[key] = val
      end
      results << hash
    end

    qs.xpath("/job_info/job_info/job_list").each do |queue|
      hash = {}
      value = queue.attributes.values[0].to_s
      hash['job_list_state'] = value
      queue.children.each do |j|
        next if j.name == 'text'
        key = j.name
        val = j.children.to_s
        if val.integer?
          val = val.to_i
        elsif val.float?
          val = val.to_f
        end
        hash[key] = val
      end
      results << hash
    end

    results
  end

  #def self.qconf_sql(str = `qconf -sql`)
  def self.queues(str = `qconf -sql`)
    str.strip.split("\n")
  end

  
  #def self.queue_jobs(qname, str = `qconf -sql`)
  def self.queue_jobs(qname, io = nil)
    io ||= IO.popen("qstat -q #{qname} -u '*' -xml", "r+") 
    results = []
    qs = Nokogiri::XML(io)
    qs.xpath("/job_info/queue_info/job_list").each do |queue|
      hash = {}
      value = queue.attributes.values[0].to_s
      hash['job_list_state'] = value
      queue.children.each do |j|
        next if j.name == 'text'
        key = j.name
        val = j.children.to_s
        if val.integer?
          val = val.to_i
        elsif val.float?
          val = val.to_f
        end
        hash[key] = val
      end
      results << hash
    end

    qs.xpath("/job_info/job_info/job_list").each do |queue|
      hash = {}
      value = queue.attributes.values[0].to_s
      hash['job_list_state'] = value
      queue.children.each do |j|
        next if j.name == 'text'
        key = j.name
        val = j.children.to_s
        if val.integer?
          val = val.to_i
        elsif val.float?
          val = val.to_f
        end
        hash[key] = val
      end
      results << hash
    end

    results
    #qs.xpath("/job_info/job_info/job_list").each do |queue|
  end

  #nj: number of jobs
  #nh: number of hosts
  #bench: benchmark time
  def self.guess_end_time(nj:, nh:, bench:)
    nj = nj.to_f
    nh = nh.to_f
    if nj < nh
      start = 0
    else
      start = nj/nh
    end
    (start + 1) * bench
  end

end
