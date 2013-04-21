require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Comana::HostSelector do
  before do
    groups_hosts = {
      "GroupA" => ["A00", "A01"],
      "GroupB" => ["B00", "B01", "B02"]
    }
    @hs00 = Comana::HostSelector.new(groups_hosts)
  end

  context 'when it has hosts' do # 'when stack is empty'
    describe '#select_all' do # ''
      #context 'input for method' do
      #end
      it 'should return all hosts' do
        @hs00.select_all.should == ["A00", "A01", "B00", "B01", "B02"]
      end
    end

    describe '#select_group' do # ''
      #context 'input for method' do
      #end
      it 'should return hosts in GroupA' do
        @hs00.select_group("GroupA").should == ["A00", "A01"]
      end

      it 'should raise Comana::HostSelector::NoEntryError' do
        lambda{@hs00.select_group("GroupNil")}.should raise_error(Comana::HostSelector::NoEntryError)
      end
    end

    describe '#groups' do # ''
      it 'should return all groups' do
        @hs00.groups.should == ["GroupA", "GroupB"]
      end
    end
  end
end

