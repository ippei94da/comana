#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"


class TC_GridEngine < Test::Unit::TestCase
  #def setup
  #  @g00 = Comana::GridEngine.new
  #end

  def test_write_qsub_script
    io = StringIO.new

    Comana::GridEngine.write_qsub_script(
      q_name:  'Cd.q',
      pe_name: 'Cd.openmpi',
      ppn: '4',
      ld_library_path: '/usr/lib:/usr/local/lib:/opt/intel/mkl/lib/intel64:/opt/intel/lib/intel64:/opt/intel/lib:/opt/openmpi-intel/lib',
      command: '/opt/openmpi-intel/bin/mpiexec -machinefile machines -np $NSLOTS /opt/bin/vasp5212openmpi',
      io: io
    )
    io.rewind
    results = io.readlines
    corrects = [
      "#! /bin/sh\n",
      "#$ -S /bin/sh\n",
      "#$ -cwd\n",
      "#$ -o stdout\n",
      "#$ -e stderr\n",
      "#$ -q Cd.q\n",
      "#$ -pe Cd.openmpi 4\n",
      "MACHINE_FILE='machines'\n",
      "LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/opt/intel/mkl/lib/intel64:/opt/intel/lib/intel64:/opt/intel/lib:/opt/openmpi-intel/lib\n",
      "export LD_LIBRARY_PATH\n",
      "cd $SGE_O_WORKDIR\n",
      "printenv | sort > printenv.log\n",
      "cut -d ' ' -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE\n",
      "/opt/openmpi-intel/bin/mpiexec -machinefile machines -np $NSLOTS /opt/bin/vasp5212openmpi\n",
    ]
    assert_equal(corrects, results)
    
  end

  def test_qstat_f
    results = Comana::GridEngine.qstat_f(File.open('test/gridengine/qstatf1.xml', 'r'))
    corrects = [
      {'name' =>'Ag.q@Ag00.calc.atom',
       'qtype' =>'BIP',
       'slots_used' =>4,
       'slots_resv' =>0,
       'slots_total' =>4,
       'arch' =>'lx26-amd64'},

      {'name' =>'Ag.q@Ag01.calc.atom',
       'qtype' =>'BIP',
       'slots_used' =>4,
       'slots_resv' =>0,
       'slots_total' =>4,
       'arch' =>'lx26-amd64'},

      {'name' =>'Cd.q@Cd00.calc.atom',
       'qtype' =>'BIP',
       'slots_used' =>0,
       'slots_resv' =>0,
       'slots_total' =>4,
       'arch' =>'lx26-amd64'},

      {'name' =>'Cd.q@Cd02.calc.atom',
       'qtype' =>'BIP',
       'slots_used' =>0,
       'slots_resv' =>0,
       'slots_total' =>4,
       'state' => 'au',
      },
    ]
    assert_equal(corrects, results)
  end

  def test_queue_alive_hosts
    results = Comana::GridEngine.queue_alive_hosts(File.open('test/gridengine/qstatf1.xml', 'r'))
    corrects = {
      'Ag.q' => ["Ag00.calc.atom", "Ag01.calc.atom"],
      'Cd.q' => ['Cd00.calc.atom']
    }
    assert_equal(corrects, results)
  end

  def test_queue_alive_num
    results = Comana::GridEngine.queue_alive_nums(File.open('test/gridengine/qstatf1.xml', 'r'))
    corrects = {
      'Ag.q' => 2,
      'Cd.q' => 1
    }
    assert_equal(corrects, results)
  end

  def test_qstat_u
    results = Comana::GridEngine.qstat_u(File.open('test/gridengine/qstatu1.xml', 'r'))
    corrects = [
      { 'job_list_state' => "running",
        'JB_job_number' =>  26,
        'JAT_prio' => 0.75000,
        'JB_name' => 'vasp-Ag.qsub',
        'JB_owner' => 'koyama',
        'state' => 'r',
        'JAT_start_time'     => '2016-02-16T17:53:44',
        'queue_name'=> 'Ag.q@Ag01.calc.atom',
        'slots' => 4,
      }, {'job_list_state' => "running",
       'JB_job_number' =>  46,
       'JAT_prio' => 0.73443,
       'JB_name' => 'vasp-Tc.qsub',
       'JB_owner' => 'koyama',
       'state' => 'dr',
       'JAT_start_time'     => '2016-02-17T09:31:36',
       'queue_name'=> 'Tc.q@Tc04.calc.atom',
       'slots' => 4,
      }, {'job_list_state' => "running",
       'JB_job_number' => 283,
       'JAT_prio' => 0.51059,
       'JB_name' => 'vasp-Ag.qsub',
       'JB_owner' => 'koyama',
       'state' => 'r',
       'JAT_start_time'     => '2016-02-26T18:10:43',
       'queue_name'=> 'Ag.q@Ag05.calc.atom',
       'slots' => 4,
      }, {'job_list_state' => "pending",
       'JB_job_number' => 468,
       'JAT_prio' => 0.25000,
       'JB_name' => 'vasp-Ga.qsub',
       'JB_owner' => 'ippei',
       'state' => 'qw',
       'JB_submission_time' => '2016-03-08T15:43:29',
       'queue_name'=> '',
       'slots' => 4,
      },
    ]
    #assert_equal(corrects[3], results[3])
    assert_equal(corrects, results)
  end

  def test_queues
    str = "Ag.q\nGa.q"
    results = Comana::GridEngine.queues(str)
    corrects = ['Ag.q', 'Ga.q']
    assert_equal(corrects, results)

    #pp results = Comana::GridEngine.queues
  end

  def test_queue_jobs
    io = File.open('test/gridengine/qstatq1.xml', 'r')
    results = Comana::GridEngine.queue_jobs('Ga.q', io)
    corrects = [
      {"job_list_state"=>"running",
      "JB_job_number"=>557,
      "JAT_prio"=>0.25,
      "JB_name"=>"vasp-Ga.qsub",
      "JB_owner"=>"ippei",
      "state"=>"r",
      "JAT_start_time"=>"2016-03-08T16:59:02",
      "queue_name"=>"Ga.q@Ga00.calc.atom",
      "slots"=>4},
      {"job_list_state"=>"running",
      "JB_job_number"=>563,
      "JAT_prio"=>0.25,
      "JB_name"=>"vasp-Ga.qsub",
      "JB_owner"=>"ippei",
      "state"=>"r",
      "JAT_start_time"=>"2016-03-08T16:59:02",
      "queue_name"=>"Ga.q@Ga01.calc.atom",
      "slots"=>4},
      {"job_list_state"=>"pending",
      "JB_job_number"=>564,
      "JAT_prio"=>0.25,
      "JB_name"=>"vasp-Ga.qsub",
      "JB_owner"=>"ippei",
      "state"=>"qw",
      "JB_submission_time"=>"2016-03-08T16:58:13",
      "queue_name"=>"",
      "slots"=>4}
    ]
    assert_equal(corrects, results)
  end

  def test_guess_end_time
    assert_equal(1.00, Comana::GridEngine.guess_end_time(nj: 0, nh: 4, bench: 1.0))
    assert_equal(1.00, Comana::GridEngine.guess_end_time(nj: 1, nh: 4, bench: 1.0))
    assert_equal(1.00, Comana::GridEngine.guess_end_time(nj: 2, nh: 4, bench: 1.0))
    assert_equal(1.00, Comana::GridEngine.guess_end_time(nj: 3, nh: 4, bench: 1.0))
    assert_equal(2.00, Comana::GridEngine.guess_end_time(nj: 4, nh: 4, bench: 1.0))
    assert_equal(2.25, Comana::GridEngine.guess_end_time(nj: 5, nh: 4, bench: 1.0))
    assert_equal(2.50, Comana::GridEngine.guess_end_time(nj: 6, nh: 4, bench: 1.0))

    assert_equal(2.00, Comana::GridEngine.guess_end_time(nj: 0, nh: 4, bench: 2.0))
    assert_equal(2.00, Comana::GridEngine.guess_end_time(nj: 1, nh: 4, bench: 2.0))
    assert_equal(2.00, Comana::GridEngine.guess_end_time(nj: 2, nh: 4, bench: 2.0))
    assert_equal(2.00, Comana::GridEngine.guess_end_time(nj: 3, nh: 4, bench: 2.0))
    assert_equal(4.00, Comana::GridEngine.guess_end_time(nj: 4, nh: 4, bench: 2.0))
    assert_equal(4.50, Comana::GridEngine.guess_end_time(nj: 5, nh: 4, bench: 2.0))
    assert_equal(5.00, Comana::GridEngine.guess_end_time(nj: 6, nh: 4, bench: 2.0))
  end
end
