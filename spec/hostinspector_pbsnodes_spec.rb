require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

$DEBUG = true

describe Comana::HostInspector::Pbsnodes do

  context 'alive host' do
    before do
      @p00 = Comana::HostInspector::Pbsnodes.new("Br10")
    end

    describe '#state' do
      it do
        @p00.name.should  == "Br10"
        @p00.state.should == "free"
        @p00.np.should    == "1"
        @p00.properties.should == "Br"
        @p00.ntype.should      == "cluster"
        #@p00.status.should     == "rectime=1368099478,varattr=,jobs=,state=free,netload=1636471502,gres=,loadave=0.00,ncpus=4,physmem=12322444kb,availmem=20402856kb,totmem=20702856kb,idletime=1389153,nusers=0,nsessions=? 0,sessions=? 0,uname=Linux Br10 3.0.0-12-server #20-Ubuntu SMP Fri Oct 7 16:36:30 UTC 2011 x86_64,opsys=linux"
        @p00.status.should     == {
          "rectime"   => "1368099478",
          "varattr"   => "",
          "jobs"      => "",
          "state"     => "free",
          "netload"   => "1636471502",
          "gres"      => "",
          "loadave"   => "0.00",
          "ncpus"     => "4",
          "physmem"   => "12322444kb",
          "availmem"  => "20402856kb",
          "totmem"    => "20702856kb",
          "idletime"  => "1389153",
          "nusers"    => "0",
          "nsessions" => "? 0",
          "sessions"  => "? 0",
          "uname"     => "Linux Br10 3.0.0-12-server #20-Ubuntu SMP Fri Oct 7 16:36:30 UTC 2011 x86_64",
          "opsys"     => "linux"
        }
        @p00.gpus.should       == "0"
      end
    end
  end

  context 'exist and alive' do
    before do
      @p01 = Comana::HostInspector::Pbsnodes.new("Br09")
    end
  
    describe '#ping and #alive?' do
      it do
        @p01.name.should  == "Br09"
        @p01.state.should == "down"
        @p01.np.should    == "1"
        @p01.properties.should == "Br"
        @p01.ntype.should      == "cluster"
        #@p01.status.should     == ""
        @p01.status.should     == {}
        @p01.gpus.should       == "0"
      end
    end
  end
end

