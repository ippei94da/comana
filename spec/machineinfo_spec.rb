#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/machineinfo.rb"

describe MachineInfo do
  describe "#load_file" do
    context "not exist machineinfo file" do
      DATA_FILE = "spec/machineinfo"
      #DATA_FILE = "spec/dummy.yaml"
      #data = {
      #  "Host1" => { "data1" => "1-1", "data2" => "1-2" },
      #  "Host2" => { "data1" => "2-1", "data2" => "2-2" },
      #}
      #io = File.open(DATA_FILE, "w")
      #YAML.dump(data, io)
      #io.close

      #pp File.open(DATA_FILE, "r").readlines

      it { lambda{MachineInfo.load_file(DATA_FILE)}.should_not raise_error}

      mi00 = MachineInfo.load_file(DATA_FILE)
      it {mi00.get_host("Host1").should == { "data1" => "1-1", "data2" => "1-2" } }

      #FileUtils.rm DATA_FILE
    end

    context "not exist machineinfo file" do
      it { lambda{ MachineInfo.load_file("") }.should raise_error(Errno::ENOENT) }
    end
  end

  describe "#get_host" do
    before do
      @mi00 = MachineInfo.new({
        "Host1" => { "data1" => "1-1", "data2" => "1-2" },
        "Host2" => { "data1" => "2-1", "data2" => "2-2" },
      })
    end

    context "exist in data" do
      subject { @mi00.get_host("Host1") }
      it {should == { "data1" => "1-1", "data2" => "1-2" } }
    end

    context "no entry" do
      it {lambda{@mi00.get_host("")}.should raise_error(MachineInfo::NoEntryError)}
    end
  end

end

