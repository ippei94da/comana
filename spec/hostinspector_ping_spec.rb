require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Comana::HostInspector::Ping do
  context 'not exist or down' do
    before do
      @hi00 = Comana::HostInspector::Ping.new("")
    end

    describe '#alive?' do
      it do
        @hi00.alive?.should == false
      end
    end
  end

  context 'exist and alive' do
    before do
      @hi00 = Comana::HostInspector::Ping.new("localhost")
    end
  
    describe '#alive?' do
      it do
        @hi00.alive?.should == true
      end
    end
  end

end

