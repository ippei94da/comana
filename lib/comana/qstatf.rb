#! /usr/bin/env ruby
# coding: utf-8


#
#
#
class QstatF
  #
  def initialize(io = IO.popen("qstat -f -xml", "r+"))
    @data = Nokogiri::XML(io)
  end

  #def self.load_file(path)
  #  #open で io をうけとれるらしい。
  #  #self.new(data)
  #end



end



#
#
#qstat -u '*' -xml 
#
#
