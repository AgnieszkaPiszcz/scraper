require "async"
require "httparty" 
require "nokogiri"
require 'pp'


Encoding.default_external = "UTF-8"

# start = Time.now

module Scraper
    module_function
    def get_car_info_from_article_element(item)
        name = item.xpath('.//section/div[2]/h1/a/text()')
        basic_info = item.xpath('.//section/div[3]/dl[1]/dd/text()')
        mileage = basic_info[0]
        engine = basic_info[1]
        gearshift = basic_info[2]
        year = basic_info[3]
        addtional_info = item.at_xpath('.//section/div[2]/p/text()') #.to_s.gsub!('•', '-')
        image = item.at_xpath('.//section/div/img')
        unless image.nil?
            image = image.attr("src")
        else 
            image = item.at_xpath('.//section/div[1]/div/div[1]/div/div[1]/a/img').attr("src")
        end
        location = item.at_xpath('.//section/div[3]/dl[2]/dd[1]/p/text()')
        price = item.at_xpath('.//section/div[4]/div[2]/div[1]/h3/text()')
        {
            :name => name.to_s.force_encoding('utf-8'),
            :price => price.to_s.force_encoding('utf-8'),
            :year => year.to_s.force_encoding('utf-8'),
            :location => location.to_s.force_encoding('utf-8'),
            :mileage => mileage.to_s.force_encoding('utf-8'),
            :engine => engine.to_s.force_encoding('utf-8'),
            :gearshift => gearshift.to_s.force_encoding('utf-8'),
            :addtional_info => addtional_info.to_s.force_encoding('utf-8'),
            :image => image.to_s.force_encoding('utf-8'),
        }
    end

    def get_results_from_page(page) 
        url = "https://www.otomoto.pl/osobowe/bmw?page=#{page.to_s}"
        begin
            response = HTTParty.get("https://www.otomoto.pl/osobowe/bmw")
        rescue HTTParty::Error => e
            puts "Http client error: #{e.class}. Try again"
            exit(1)
        end

        case response.code
        when 200
            nil
        else
            puts "Request failed with code: #{response.code}. Try again."
            exit(1)
        end

        body = response.body.force_encoding('utf-8')
        document = Nokogiri::HTML(body, nil, 'utf-8')
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

    def get_cars()
        1.upto(4).map { |i|
            get_results_from_page(i)
        } 
        .concat
        .flatten!
    end
end

# Presenter::create_pdf


# puts "Duration: #{Time.now - start}"

