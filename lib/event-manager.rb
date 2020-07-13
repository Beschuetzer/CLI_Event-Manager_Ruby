
def clean_zipcode (zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode (zipcode)
  begin
   civic_info.representative_info_by_address(
     address: zipcode, 
     levels: 'country', 
     roles: ['legislatorUpperBody', 'legislatorLowerBody'],
    ).officials
    
    # legislator_names = legislators.map(&:name)
    # legislators = legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

require 'csv'
require 'yaml'
require 'erb'
require 'google/apis/civicinfo_v2'
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
#header is ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode
#CSV turns these into symbls via headers_converters: :symbol (Email_address becomes :email_address)
contents = CSV.open "./small_sample.csv", headers: true, header_converters: :symbol
template_letter = File.read "../form_letter.erb"
erb_template = ERB.new(template_letter)

contents.each{|row| 
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  yaml_file_name = "./#{name}'s_represnetatives.txt"
  legislators = YAML::load(yaml_file_name)
  p legislators
  legislators = legislators.officials if legislators.is_a?(Array)
  msg = "#{name} #{zipcode} #{legislators}"
  personalized_letter = erb_template.result(binding)

  dir = "./form_letters"
  Dir.mkdir dir unless Dir.exists? dir
  output_filename = "#{dir}/thank_you_#{name}\.html"
  File.open(output_filename, 'w'){|file| file.write(personalized_letter)}
}

#when using whole object






