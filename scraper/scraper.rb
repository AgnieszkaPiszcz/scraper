require "async"
require "httparty" 
require "nokogiri"
require 'pp'


Encoding.default_external = "UTF-8"

##
# This module contains the methods used for scraping car advertisements from otomoto.pl
module Scraper
    module_function
    ##
    # A helper method which extracts car data such as name, price, engine type etc. from a html element containing a single ad
    # and returns a hash representing info about a single car.
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

    ##
    # Returns a list of hashes with car data from one page of search results
    def get_results_from_html(body) 

        document = Nokogiri::HTML(body, nil, 'utf-8')
        document
            .xpath('//main/div[2]/div/div[3]/div[3]/div/article')
            .map { |item| get_car_info_from_article_element(item) }
    end

    ##
    # Fetches the url and returns the response body.
    def get_html(url)
        begin
            response = HTTParty.get(url)
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

        response.body.force_encoding('utf-8')
    end

    ##
    # Asynchronously downloads 4 pages of search results and returns a list of hashes with car data from these 4 pages.
    def async_get_cars()
        Async do 
            1.upto(4).map { |i|
                url = "https://www.otomoto.pl/osobowe/bmw?page=#{i}"
                html = get_html(url)
                Async do
                    get_results_from_html(url)
                end
            } 
            .map(&:wait)
            .concat
            .flatten!
        end
    end

    ##
    # Returns a list of hashes with car data from 4 pages of search results
    def get_cars(n)
        1.upto(n).map { |i|
            url = "https://www.otomoto.pl/osobowe/bmw?page=#{i}"
            html = get_html(url)
            get_results_from_html(html)
        } 
        .concat
        .flatten!
    end
end


