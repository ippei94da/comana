#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/machineinfo.rb"

describe Comana::MachineInfo do
  describe "#load_file" do
    context "not exist machineinfo file" do
      DATA_FILE = "example/machineinfo"
      it { lambda{Comana::MachineInfo.load_file(DATA_FILE)}.should_not raise_error}

      mi00 = Comana::MachineInfo.load_file(DATA_FILE)
      it {mi00.get_info("SeriesA").should == { "data1" => "A-1", "data2" => "A-2" } }
    end

    context "not exist machineinfo file" do
      it { lambda{ Comana::MachineInfo.load_file("") }.should raise_error(Errno::ENOENT) }
    end
  end

  describe "#get_info" do
    before do
      @mi00 = Comana::MachineInfo.new({
        "SeriesA" => { "data1" => "A-1", "data2" => "A-2" },
        "SeriesB" => { "data1" => "B-1", "data2" => "B-2" },
      })
    end

    context "mach to hostname in data" do
      subject { @mi00.get_info("SeriesA") }
      it {should == { "data1" => "A-1", "data2" => "A-2" } }
    end

    context "series name + integers" do
      subject { @mi00.get_info("SeriesA00") }
      it {should == { "data1" => "A-1", "data2" => "A-2" } }
    end

    context "series name + alphabet" do
      it {lambda{@mi00.get_info("seriesAB")}.should raise_error(Comana::MachineInfo::NoEntryError)}
    end

    context "no entry" do
      it {lambda{@mi00.get_info("")}.should raise_error(Comana::MachineInfo::NoEntryError)}
    end
  end

end

