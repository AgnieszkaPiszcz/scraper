require "async"
require "httparty" 
require "nokogiri"
require 'pp'
require 'prawn'

start = Time.now
def get_car_info_from_article_element(item)
    name = item.xpath('.//section/div[2]/h1/a/text()')
    basic_info = item.xpath('.//section/div[3]/dl[1]/dd/text()')
    mileage = basic_info[0]
    engine = basic_info[1]
    gearshift = basic_info[2]
    year = basic_info[3]
    addtional_info = item.at_xpath('.//section/div[2]/p/text()')
    image = item.at_xpath('.//section/div/img')
    unless image.nil?
        image = image.attr("src")
    else 
        image = item.at_xpath('.//section/div[1]/div/div[1]/div/div[1]/a/img').attr("src")
    end
    location = item.at_xpath('.//section/div[3]/dl[2]/dd[1]/p/text()')
    price = item.at_xpath('.//section/div[4]/div[2]/div[1]/h3/text()')
    {
        :name => name.to_s,
        :price => price.to_s,
        :year => year.to_s,
        :location => location.to_s,
        :mileage => mileage.to_s,
        :engine => engine.to_s,
        :gearshift => gearshift.to_s,
        :addtional_info => addtional_info.to_s,
        :image => image.to_s,
    }
end

def get_results_from_page(page) 
    url = "https://www.otomoto.pl/osobowe/bmw?page=#{page.to_s}"
    response = HTTParty.get("https://www.otomoto.pl/osobowe/bmw")
    document = Nokogiri::HTML(response.body)
    document
        .xpath('//main/div[2]/div/div[3]/div[3]/div/article')
        .map { |item| get_car_info_from_article_element(item) }
end

def async_get_cars()
    Async do 
        1.upto(4).map { |i|
            Async do
                get_results_from_page(i)
            end
        } 
        .map(&:wait)
        .concat
        .flatten!
    end
end

def create_csv()
    cars = async_get_cars().wait
    csv = CSV.open("cars.csv", "wb") do |csv|
        csv << cars.first.keys 
        cars.each do |car|
          csv << car.values
        end
    end   
end

def create_pdf() 
    csv = File.open('cars.csv').read.lines.to_a.join.force_encoding('iso-8859-2').encode('utf-8')
    pdf = Prawn::Document.new
    pdf.font_families.update("roboto"=>{:normal =>"Roboto/Roboto-Black.ttf"})
    pdf.font("roboto")
    pdf.text(csv)
    pdf.render_file('cars.pdf') 

end

create_csv

create_pdf


puts "Duration: #{Time.now - start}"

