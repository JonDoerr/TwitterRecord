puts("starting\n");

#initialize the keys 
private_arr = Array.new(4)
i = 0
File.open("private", "r") do |f|
  f.each_line do |line|
    num = line.length - 2
    private_arr[i] = line[0..num]
    puts "#{i}" + line
    i = i + 1
  end
end

# time to test twitter api
require 'twitter'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'date'

Yesterday = Date.today.prev_day
month = Yesterday.month
day = Yesterday.day


dc = true
#############################################################################################
#                                  Begin Scraping Daily Temps Code                          #
#                                          Washington D.C.                                  #
#############################################################################################
if dc 
site = Nokogiri::HTML(open('https://www.timeanddate.com/weather/usa/washington-dc/historic'))
#binding.pry

# https://www.timeanddate.com/weather/usa/washington-dc/historic
# https://sercc.com/cgi-bin/sercc/cliMAIN.pl?md0015
str = site.css('p').text
puts str

if(str.match(/Maximum temperature yesterday: (\d*)/)) 
  max = $1
  puts "The maximum for yesterday was " + max
end

if(str.match(/Minimum temperature yesterday: (\d*)/)) 
  min = $1
  puts "The maximum for yesterday was " + min
end

#############################################################################################
#                                  Begin Scraping Record Temps Code                         #
#                                          Washington D.C.                                  #
#############################################################################################

#"Enums" for daysArr to make it less confusing
DY = 0
NMX = 1
NMN = 2
NPCP = 3
NS = 4
RMX = 5 #sometimes 4 sometimes 5
LOMX = 7
RMN = 9
HIMN = 11
MXPCP = 13
MXSN = 15

site2 = Nokogiri::HTML(open('https://www.weather.gov/lwx/dcanme'))
full = site2.css('pre').text

months = full.split("DAILY NORMALS AND RECORDS FOR THE MONTH OF")

current_Month_Text = months[month]
curr = current_Month_Text.slice(/YEAR(\s|\S)*\*/) # daysArr[index] where index is the actual day we want. i.e daysArr[1] = the first day of the month
daysArr = curr.split("\n")

daysArr.each { |s| s.gsub!(/[\+\*\/]/,' '); puts s}
  
Day_DATA_Arr = daysArr[day].split(" ")
#binding.pry

dayRecordMax = Day_DATA_Arr[RMX]
dayRecordLow = Day_DATA_Arr[RMN]

puts Day_DATA_Arr

for i in 0..15 
  puts Day_DATA_Arr[i]
end

puts dayRecordMax
puts dayRecordLow



#############################################################################################
#                                  Begin Twitter Code                                       #
#                                    Washington D.C.                                        #  
#############################################################################################

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = private_arr[0]
  config.consumer_secret     = private_arr[1]
  config.access_token        = private_arr[2]
  config.access_token_secret = private_arr[3]
end

puts max
puts dayRecordMax
maxltdayrecord = max.to_i < dayRecordMax.to_i

puts "#{max} < #{dayRecordMax}: #{maxltdayrecord}"
if(max.to_i < dayRecordMax.to_i)
  TweetText = "For Washington D.C., the maximum temperature for yesterday was #{max} which was #{dayRecordMax.to_i - max.to_i} less than the recorded maximum of #{dayRecordMax} for #{month}-#{day}, which was set in #{Day_DATA_Arr[RMX+1]}"
elsif
  TweetText = "A new record high temperature was set for #{month}-#{day} in Washington D.C. at #{max} with the previous record being #{dayRecordMax}"
end
puts TweetText

client.update(TweetText)
#token = @client.consumer_key + "&" + @client.consumer_secret
#tweets = client.user_timeline('rubyinside', count: 20)
#client.update("Test");




end
newyork = false
if newyork
#############################################################################################
#                                  Begin Scraping Daily Temps Code                          #
#                                          New York City                                    #
############################################################################################# 
#https://www.timeanddate.com/weather/usa/new-york/historic

site = Nokogiri::HTML(open('https://www.timeanddate.com/weather/usa/new-york/historic'))
#binding.pry

str = site.css('p').text
puts str

if(str.match(/Maximum temperature yesterday: (\d*)/)) 
  max = $1
  puts "The maximum for yesterday was " + max
end

if(str.match(/Minimum temperature yesterday: (\d*)/)) 
  min = $1
  puts "The maximum for yesterday was " + min
end

#############################################################################################
#                                  Begin Scraping Daily Temps Code                          #
#                                          New York City                                    #
#############################################################################################
#https://forecast.weather.gov/product.php?site=NWS&issuedby=NYC&product=CLI&format=CI&version=1&glossary=1&highlight=off
site2 = Nokogiri::HTML(open('https://forecast.weather.gov/product.php?site=NWS&issuedby=NYC&product=CLI&format=CI&version=1&glossary=1&highlight=off'))
#binding.pry
full = site2.css('pre#proddiff.glossaryProduct').text
full.match(/MAXIMUM \s*\d*\s*\d* (AM|PM)\s*(\d*)\s*(\d*)/)

dayRecordMax = $2
year = $3

#binding.pry
#dayRecordMax = Day_DATA_Arr[RMX]
#dayRecordLow = Day_DATA_Arr[RMN]

puts dayRecordMax
puts year
#puts dayRecordLow
end