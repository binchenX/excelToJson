#!/usr/bin/env ruby


require 'csv'     
require 'rubygems'   

class MovieData
                     
    @@URI_ROOT = "http://192.168.1.102/video"
    
    def initialize keys , values  
           #values is type of Array
           @values = values         
          # @keys = "Genre,Title,Poster,Cast,Director,Storyline,Release Date,Country,Series"   
           @keys = keys
           if(@values.size != @keys.size)
              puts "ERROR: values number should match key numbers "          
              exit
           end
           @keyNums = @keys.size   
    end       
    
    def qoto s
       "\"#{s}\""
    end           
    
    def toJson
      json = "{"
      @keys.each_with_index do |key ,index|  
              #value = @values.split(",")[index].strip      
              #ingore the suffix
              value = @values[index].strip   
                                               
              if(key.casecmp("Filename").zero? )
                 value = @@URI_ROOT + "/"+ value + ".mp4"
              end        
              
              if(key.casecmp("poster").zero?)
                 value = @@URI_ROOT + "/" + value + ".jpg"
              end
              #if the key is either poster or filename , add the URI root
              json << "#{qoto(key)}:#{qoto(value)}"   
              json << ",\n"  unless index == ( @keyNums-1)
      end   
      
       json  << "}" 
       #puts json
       json  
    end 
  
end               
                  

def convert_csv_to_json csv_file, out_json
        
                   json_file = out_json       
                   is_first_line = true
                   File.delete(json_file)   if File.exist?(json_file)
                   f = File.open(json_file,"w")           
                   f << '['                          
                   
                   #it is cool that the CSV could handle the the filed that contains comma(,)  - may be just because 
                   #that are not utf-8 comma???
                   #alternative is that you could add the comman manually                     
                  rows =  CSV.parse(File.read(csv_file))    
                               
                  #the first row is key
                  key = rows[0]
                  
                  rows.each_with_index do |line, index|
                        if (index != 0)                 
                        #puts "process one line #{index} #{line}"
                        f << MovieData.new(key, line).toJson 
                        f << ",\n\n" unless index == (rows.size - 1)
                      end
                    
                  end
                  
                   f << ']'
  
end 
                     

            

if ARGV.size != 1   
  puts "usage : toJson input"                        
  exit
end 
                       
         
        
      
input = ARGV.shift
output = input.split(".")[0] + ".json";  

puts "convert #{input} to #{output}" 

i_utf8 = input.split(".")[0] + "_utf8.csv";

File.delete(i_utf8) if File.exist?(i_utf8)
      
iff =  File.open(i_utf8,"w")   

#process the input file before convert  - replace the 0xa0???

temp = File.read(input)
  
#the csv file contains a invalied byte '0xA0'   
#replace the invalid bytes with " "
processed_temp = temp.encode("utf-8","gb2312",{:invalid=>:replace, :replace=>" "})
                  
#replace the '\r\space' to '\r'      
processed_temp.gsub!('\r','\n')

iff << processed_temp 
puts "convert to utf-8 done. check #{i_utf8}"  
         
#close and save the intermited file
iff.close


convert_csv_to_json iff , output  
puts "Done.\nCheck #{output}" 
            



