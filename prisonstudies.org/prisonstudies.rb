#!/usr/bin/env ruby -w

#
# To install nokogiri : gem install nokogiri
#
require "nokogiri"
require "open-uri"
require "csv"

require File.join(File.dirname(__FILE__), '..', 'filters.rb')

# 1. Import country mapping CSV file to make the mapping between prisonstudies Country ID and ISO_ALPHA3 Country Code
country_mapping = Hash.new

CSV.foreach(File.join(File.dirname(__FILE__), 'country_mapping.csv')) do |row|
  id = row[0]
  country_infos = {:iso_a3 => row[1], :name => row[2]}
  country_mapping[id] = country_infos
end

# 2. Get the list of every country
page = Nokogiri::HTML(open("http://www.prisonstudies.org/info/worldbrief/wpb_stats.php?area=all&category=wb_poprate"))

countries = []    # Store data about every countries
countries_trends = []

country_list = page.css(".item-page table tr")

total_countries = country_list.size
extracted_countries = 0

country_list.each do |country_list_line|

  country = {             # Store every data of the current country. Will be added to countries array
    :id => "",
    :name => "",
    :iso_a3 => "",
    :iso_name => "",
    :pop_total => "",
    :pop_rate => "",
    :pre_trial_rate => "",
    :female_rate => "",
    :minors_rate => "",
    :foreigners_rate => "",
    :establishments_number => "",
    :official_capacity => "",
    :occupancy_level => "",
    :source => ""
  }

  country[:id] = country_list_line.css("td:nth-child(2) a").attribute("href").to_s.delete "wpb_country.php?country="

  # 3. We have the country id, now we scrap the page containing data about this specific country
  country_url = "http://www.prisonstudies.org/info/worldbrief/wpb_country.php?country=#{country[:id]}"

  extracted_countries += 1
  puts "[#{extracted_countries}/#{total_countries}]  Fetching : #{country_url}"

  country_page = Nokogiri::HTML(open(country_url))

  country_infos = country_page.css(".item-page table tr")

  country[:name] = country_infos[0].css("td:nth-child(2)").text.strip
  puts "Extracting data for country: #{country[:name]}"

  country[:iso_a3] = country_mapping[country[:id]][:iso_a3]
  country[:iso_name] = country_mapping[country[:id]][:name]

  country_infos.each do |country_infos_line|
    if country_infos_line.css("td:nth-child(1)").text.start_with? "Prison population total"
      pop_total = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      pop_total = filter_non_number_characters(pop_total)
      country[:pop_total] = pop_total

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Prison population rate"
      pop_rate = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      pop_rate = percentage_to_float(pop_rate, 100000)
      country[:pop_rate] = pop_rate

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Pre-trial detainees"
      pre_trial_rate = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      pre_trial_rate = percentage_to_float(pre_trial_rate)
      country[:pre_trial_rate] = pre_trial_rate

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Female prisoners"
      female_rate = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      female_rate = percentage_to_float(female_rate)
      country[:female_rate] = female_rate

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Juveniles"
      minors_rate = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      minors_rate = percentage_to_float(minors_rate)
      country[:minors_rate] = minors_rate

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Foreign"
      foreigners_rate = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["c."])
      foreigners_rate = percentage_to_float(foreigners_rate)
      country[:foreigners_rate] = foreigners_rate

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Number of establishments"
      establishments_number = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["*"])
      establishments_number = filter_non_number_characters(establishments_number)
      country[:establishments_number] = establishments_number

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Official capacity"
      official_capacity = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["*"])
      official_capacity = filter_non_number_characters(official_capacity)
      country[:official_capacity] = official_capacity

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Occupancy level"
      occupancy_level = filter_string(country_infos_line.css("td:nth-child(2) b").text, ["*"])
      occupancy_level = percentage_to_float(occupancy_level)
      country[:occupancy_level] = occupancy_level

    elsif country_infos_line.css("td:nth-child(1)").text.start_with? "Recent prison population trend"
      trends = country_infos_line.css("td:nth-child(2) table tr")

      trends.each do |trends_lines|
        trend = {}
        trend[:id] = country[:id]
        trend[:iso_a3] = country_mapping[country[:id]][:iso_a3]
        trend[:iso_name] = country_mapping[country[:id]][:name]
        trend[:year] = trends_lines.css("td:nth-child(1)").text

        pop_total = filter_string(trends_lines.css("td:nth-child(2) b").text, ["c."])
        pop_total = filter_non_number_characters(pop_total)
        trend[:pop_total] = pop_total

        pop_rate = filter_string(trends_lines.css("td:nth-child(3) b").text, ["c."])
        pop_rate = percentage_to_float(pop_rate, 100000)
        trend[:pop_rate] = pop_rate

        trend[:source] = country_url
        countries_trends.push trend
      end
    end
  end

  country[:source] = country_url
  countries.push(country)
end

# 4. Generate CSV files

data_dir = File.join(File.dirname(__FILE__), '_data')
prisonstudies_countries_files = File.join(data_dir, 'prisonstudies_countries.csv')
prisonstudies_trends = File.join(data_dir, 'prisonstudies_trends.csv')

if Dir.exists?(data_dir)
  File.delete(prisonstudies_countries_files) if File.exists?(prisonstudies_countries_files)
  File.delete(prisonstudies_trends) if File.exists?(prisonstudies_trends)
else
  Dir.mkdir(data_dir)
end

if countries.size > 0
  CSV.open(prisonstudies_countries_files, "wb") do |csv|
    csv << countries[0].keys
    countries.each do |country_data|
      csv << country_data.values
    end
  end
end


if countries_trends.size > 0
  CSV.open(prisonstudies_trends, "wb") do |csv|
    csv << countries_trends[0].keys
    countries_trends.each do |country_trends_data|
      csv << country_trends_data.values
    end
  end
end
