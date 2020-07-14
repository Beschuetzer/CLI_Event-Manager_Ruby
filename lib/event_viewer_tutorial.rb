require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
#header is ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode
#CSV turns these into symbls via headers_converters: :symbol (Email_address becomes :email_address)

def get_largest_value_in_reduced_obj(object)
  largest_value = 0
  largest_key = 0
  object.each {|k, v|
    puts "k: #{k} and v: #{v}"
    if v > largest_value
      largest_value = v
      largest_key = k
      puts "largest_value: #{largest_value} and largest_key: #{largest_key}"
    end
  }
  puts largest_key,  largest_value
end

def get_day_of_week_and_hour(regdate)
  date = regdate.split('/')
  temp =date[2].split(' ')
  month = date[0]
  day = date[1]
  year = temp[0]
  time = temp[1]
  temp = time.split(':')
  hour = temp[0]
  minute = temp[1]
  hour_new = (minute.to_i.between?(16,44)) ? hour.to_f + 0.5 : (minute.to_i >= 45) ? hour.to_i + 1 : hour
  puts "Month: #{month}, Day: #{day}, Year: #{year}, Hour: #{hour}, Minute: #{minute}, hour_new: #{hour_new} "
  dateTime = DateTime.new(year.to_i,month.to_i,day.to_i,hour.to_i,minute.to_i,0)
  [dateTime.wday(),hour]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^0-9]/i, "")
  
  case phone_number.length
  when 11
    if phone_number.strip[0] == "1"
      phone_number = phone_number[1..phone_number.length-1]
      #puts "Good #: #{phone_number}"
    else
      #puts "Bad #: #{phone_number}"
      phone_number = "Bad Number"
    end
  else
    phone_number = "Bad Number"
    #puts "Bad #: #{phone_number}"
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'small_sample.csv', headers: true, header_converters: :symbol

template_letter = File.read "../form_letter.erb"
erb_template = ERB.new template_letter
hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  results = get_day_of_week_and_hour(row[:regdate])
  days << results[0]
  hours << results[1]
  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end
days_reduced = days.reduce(Hash.new(0)) {|obj, day|
  obj[day] += 1
  obj
}

hours_reduced = hours.reduce(Hash.new(0)){|obj, hour|
  obj[hour] += 1
  obj
}
p days, hours, days_reduced, hours_reduced

get_largest_value_in_reduced_obj(days_reduced)
get_largest_value_in_reduced_obj(hours_reduced)