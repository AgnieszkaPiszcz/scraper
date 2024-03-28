require 'erb'
require 'pdfkit'

module Presenter
    module_function
    def create_csv(cars)
        begin
            csv = CSV.open("output/cars.csv", "wb") do |csv|
                csv << cars.first.keys 
                cars.each do |car|
                csv << car.values
                end
            end   
        rescue CSV::Error => e
            puts "CSV handling error: #{e.class}. Try again"
            exit(1)
        end

    end

    def create_pdf(cars) 
        start = Time.now
        begin
            html = File.open('template2.erb').read
        rescue File::Error => e
            puts "File handling error: #{e.class}. Try again"
            exit(1)
        end
        template = ERB.new(html)
        file = template.result(binding)
        options = {
            :margin_top => '0.75in',
            :margin_right => '0.75in',
            :margin_bottom => '0.75in',
            :margin_left => '0.75in'
        }
        kit = PDFKit.new(file, options).to_file('output/cars.pdf')
    end
end