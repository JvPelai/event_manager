require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody','legislatorLowerBody']
        ).officials   
    rescue
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

def clean_zipcode(zipcode)
    if zipcode.nil?
        zipcode = "00000"
    else
        while zipcode.length != 5 do
            if  zipcode.length < 5
                zipcode = zipcode.rjust 5, "0"
            else  
                zipcode = zipcode.slice! zipcode[-1]
            end
        end
    end
    return zipcode
end

def clean_phone(phone_number)
    if phone_number.nil?
        number = "0"*10
    end 
    number = phone_number.split(/[" ",+,.,(,),-]/).join("")
    if number.length != 10 
        if number.length == 11 && number[0] == "1"
            number.slice! number[0]
            return number
        elsif number.length == 11 && number[0] != "1"
            return "Wrong phone number format"
        else
            return "Wrong phone number format"
        end
    else
        return phone_number 
    end
end


def save_thank_you_letter(id,form_letter)
    Dir.mkdir("output")unless Dir.exists? "output"

    filename = "output/thanks_#{id}.html"

    File.open(filename,'w') do |file|
        file.puts form_letter 
    end
end

puts "EventManager Initialized"

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
    id = row[0]
    name = row[:first_name]

    phone_number = clean_phone(row[5])

    zipcode = clean_zipcode(row[:zipcode])
    
    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)
    
end

