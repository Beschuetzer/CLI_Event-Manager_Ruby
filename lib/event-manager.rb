
def clean_zipcode (zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode (zipcode)
  begin
    legislators = civic_info.representative_info_by_address(address: zipcode, levels: 'country', roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislators_string = legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

require 'csv'
require 'yaml'

require 'google/apis/civicinfo_v2'
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
#header is ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode
#CSV turns these into symbls via headers_converters: :symbol (Email_address becomes :email_address)
contents = CSV.open "./small_sample.csv", headers: true, header_converters: :symbol
template_letter = File.read "form_letter.html"
contents.each{|row| 
  name = row[:first_name].to_s.strip
  zipcode = clean_zipcode(row[:zipcode])
  legislators_string = legislators_by_zipcode(zipcode)
  
  file_name = "#{name}'s_represnetatives.txt"
  msg = "#{name} #{zipcode} #{legislators_string}"
  personalized_letter = template_letter.gsub("FIRST_NAME", name)
  personalized_letter = personalized_letter.gsub("LEGISLATORS", legislators_string)
}

#when using whole object






