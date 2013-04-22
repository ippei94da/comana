require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Comana::HostInspector do
  #context 'not done ping' do # 'when stack is empty'
  #  before do
  #    @hi00 = "" #Not exist host
  #  end
  #
  #  #describe '#ping and #response_ping?' do # ''
  #  describe '#ping and #alive?' do # ''
  #    it 'should return' do
  #      result.should == "a"
  #    end
  #  end
  #end

  context 'not exist or down' do # 'when stack is empty'
    before do
      #@hi00 = Comana::HostInspector.new("NOT_EXIST_HOST") #Not exist host
      @hi00 = Comana::HostInspector.new("") #Not exist host
    end

    #describe '#ping and #response_ping?' do # ''
    describe '#ping' do # ''
      it 'should return false' do
        @hi00.ping.should == false
      end
    end
  end

  context 'exist and alive' do # 'when stack is empty'
    before do
      @hi00 = Comana::HostInspector.new("localhost")
    end
  
    describe '#ping and #alive?' do # ''
      it 'should return true' do
        @hi00.ping.should == true
      end
    end
  end

end

