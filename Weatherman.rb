# Weatherman practice program

# Modules Used
module DataManipulation
  # Reads names of all the files containing the data.
  def read_csv(name, headers)
    # print "Reading data from: ", name, "\n"
    require 'csv'
    aFile = File.open(name, "r+")
    cFile = File.new("temp.csv", "w+")

    cFile.syswrite(aFile.read)
    cFile.close
    aFile.close


    arr = CSV.read("temp.csv")

    if arr.empty?
      puts "Error! File Empty"
    end

    for i in arr

      if i.empty?
        arr.shift
      elsif headers.empty?
        headers = arr.shift
        break
      elsif !headers.empty?
        arr.shift
        break
      end

    end

    [arr, headers]
  end

  def read_file_names
    temp_dir = ARGV[2].to_s + "/*"

    file_names = Dir.glob(temp_dir.to_s)
    file_names
  end

  # Processes each file & saves data in 'all_data'
  def extract_data(files, headers, all_data)
    for i in files
      arr = read_csv(i, headers)

      # During processing of first file headers will get extracted.
      if headers.empty?
        headers = arr[1]
      end

      for j in arr[0]
        all_data << j
      end
    end

    [headers, all_data]
  end

  # Removes spaces at start of and at the end of hash keys (headers)
  def clean_headers(headers)
    temp_arr = []

    for i in headers
      temp_arr << i.to_s.strip
    end

    temp_arr
  end

  # Converts headers and all_data to a hash
  def make_hash(data, headers)

    hashed_data = {}
    for i in headers
      hashed_data[i] = []
    end

    for row in data
      for j in (0...(headers.count))
        hashed_data[headers[j]] << row[j]
      end
    end

    hashed_data
  end

  # Helper Function of highest_lowest_humid()
  def find_max(arr)

    index = 0
    max_value = arr[index][0].to_i

    for i in 0...arr.size
      if arr[i][0].nil? || arr[i][0].empty?
        next
      elsif arr[i][0].to_i > max_value
        max_value = arr[i][0].to_i
        index = i
      end
    end

    [max_value.to_i, arr[index][1]]
  end

  # Helper Function of highest_lowest_humid()
  def find_min(arr)

    index = 0
    min_value = arr[index][0].to_i

    for i in 0...arr.size
      if arr[i][0].nil? || arr[i][0].empty?
        next
      elsif arr[i][0].to_i < min_value
        min_value = arr[i][0].to_i
        index = i
      end
    end

    [min_value.to_i, arr[index][1]]
  end

  def values_by_year(year, key, data)

    temp = []
    index = 0

    for i in data["GST"]
      date = i.split('-')
      temp_year = date[0].to_i

      if temp_year == year
        temp << [data[key][index], data["GST"][index]]
      end
      index += 1
    end

    temp
  end

  def values_by_year_month(year, key, data)

    temp = []
    index = 0

    for i in data["GST"]
      date = i.split('-')

      temp_date = []
      temp_date << date[0].to_i
      temp_date << date[1].to_i

      if temp_date[0] == year[0].to_i && temp_date[1] == year[1].to_i
        temp << [data[key][index].to_i, data["GST"][index]]
      end
      index += 1
    end

    temp
  end

    # Performs operation of task1
  def highest_lowest_humid(data, year)

    # For Highes Temperature
    temp = values_by_year(year, "Max TemperatureC", data)
    if temp.count <= 0
      puts "Error! No records found."

    else
      # print temp, ", "
      # puts
      temperature = find_max(temp)
      puts "Highest: #{temperature[0]}C on #{temperature[1]}"
    end

    # For Lowest Temperature
    temp = values_by_year(year, "Min TemperatureC", data)
    if temp.count <= 0
      puts "Error! No records found."

    else
      temperature = find_min(temp)
      puts "Lowest: #{temperature[0]}C on #{temperature[1]}"
    end

    # For Max Humidity
    temp = values_by_year(year, "Max Humidity", data)
    if temp.count <= 0
      puts "Error! No records found."

    else
      temperature = find_max(temp)
      puts "Humidity: #{temperature[0]}% on #{temperature[1]}"
    end
  end

  def average_highest_lowest_humidity(data, date)
    date = date.split('/')
    t_date = [date[0], date[1]] # contains year and month

    records = values_by_year_month(t_date, "Max TemperatureC", data)

    # For Avg Highest
    if records.count <= 0
      puts "Highest Average: Error! No record Found"
    else
      avg = 0

      for i in records
        avg += i[0]
      end
      avg /= (records.count * 1.0)

      puts "Highest Average: #{avg}C"
    end

    # For Avg Lowest
    records = values_by_year_month(t_date, "Min TemperatureC", data)

    if records.count <= 0
      puts "Lowest Average: Error! No record Found"
    else
      avg = 0

      for i in records
        avg += i[0]
      end
      avg /= (records.count * 1.0)

      puts "Lowest Average: #{avg}C"
    end

    # For Avg Humidity
    records = values_by_year_month(t_date, "Max Humidity", data)

    if records.count <= 0
      puts "Average Humidity: Error! No record Found"
    else
      avg = 0

      for i in records
        avg += i[0]
      end
      avg /= (records.count * 1.0)

      puts "Average Humidity: #{avg}%"
    end

  end

  def draw_high_low(data, date)
    date = date.split('/')
    t_date = [date[0], date[1]] # contains year and month

    # For Highest
    records_highest = values_by_year_month(t_date, "Max TemperatureC", data)

    # For Lowest
    records_lowest = values_by_year_month(t_date, "Min TemperatureC", data)

    if records_highest.count <= 0 || records_lowest.count <= 0
      puts "Error! No record Found"
    else
      all_records = []

      # Following loop makes an array of all records combined in
      # Order that each lowest temperature comes after each highest temperature.

      for i in 0..(records_highest.count * 2 - 1)

        if i % 2 == 0
          all_records << records_highest[i / 2]
        else
          all_records << records_lowest[i / 2]
        end

      end

      counter = 0 # Used for coloring
      for i in all_records

        # temporary variables used to store day.
        temp_date = i[1].to_s.split('-')
        day = temp_date[2].to_i
        day = "0" + day.to_s if day.to_s.size == 1

        # Printing the parttern of temperature
        print " #{day} "

        i[0].to_i.times do
          require 'colorize'
          if counter % 2 == 0
            print "+".red
          else
            print "+".blue
          end
        end
        print " #{i[0]}C"
        puts

        counter += 1
      end
    end

  end

  def draw_high_low_chart(data, date)
    date = date.split('/')
    t_date = [date[0], date[1]] # contains year and month

    # For Highest
    records_highest = values_by_year_month(t_date, "Max TemperatureC", data)

    # For Lowest
    records_lowest = values_by_year_month(t_date, "Min TemperatureC", data)

    if records_highest.count <= 0 || records_lowest.count <= 0
      puts "Error! No record Found"
    else
      all_records = []

      # Following loop makes an array of all records combined in
      # Order that each lowest temperature comes after each highest temperature.

      for i in 0..(records_highest.count * 2 - 1)

        if i % 2 == 0
          all_records << records_highest[i / 2]
        else
          all_records << records_lowest[i / 2]
        end

      end

      for i in (0...all_records.count / 2)

        # temporary variables used to store day.
        temp_date = all_records[i * 2][1].to_s.split('-')
        day = temp_date[2].to_i
        day = "0" + day.to_s if day.to_s.size == 1

        # Printing the parttern of temperature
        print " #{day} "

        require 'colorize'

        low_temp = all_records[(i * 2) + 1][0]
        high_temp = all_records[(i * 2)][0]

        low_temp.to_i.times do
          print "+".blue
        end

        high_temp.to_i.times do
          print "+".red
        end

        print " #{low_temp}C - #{high_temp}C"
        puts

      end
    end
  end

end
# End of Module 'DATA_MANIPULATION'

class Weatherman
  include DataManipulation


  def initialize()
    @all_files = []
    @headers = []
    @all_data = []
    @h_data = {}

    @all_files = read_file_names()
    temp = extract_data(@all_files, @headers, @all_data)
    @headers = temp[0]
    @all_data = temp[1]
    @headers = clean_headers(@headers)
    @h_data = make_hash(@all_data, @headers)
  end

  def find_task()
    if ARGV[0] == "-e"
      self.task_1()

    elsif ARGV[0] == "-a"
      self.task_2()

    elsif ARGV[0] == "-c"
      self.task_3()

    elsif ARGV[0] == "-d"
      self.task_4()

    else
      puts "Error! Invalid Arguments"
    end
  end
  # Tasks
  def task_1()

    highest_lowest_humid(@h_data, ARGV[1].to_i)
  end

  def task_2()
    average_highest_lowest_humidity(@h_data, ARGV[1].to_s)
  end

  def task_3()
    draw_high_low(@h_data, ARGV[1].to_s)
  end

  def task_4()
    draw_high_low_chart(@h_data, ARGV[1].to_s)
  end

end

def check_args()
  if ARGV.count != 3
    puts "Error! Invalid Number of Arguments"
    return false
  end

  # argvs = ARGV.to_s
  # argvs = argvs.split(' ')

  # if argvs[0] != "-e" && argvs[0] != "-a" && argvs[0] != "-c" && argvs[0] != "-b"
  #   puts "Error! Invalid Arguments"
  #   return false

  # elsif !File.directory?(ARGV[2].to_s)
  #   puts "Error! Invalid Arguments"
  #   return false
  # end

  return true
end

if check_args()
  obj = Weatherman.new()
  obj.find_task()
end


# CODE DUMP
