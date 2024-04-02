require 'minitest/autorun'
require_relative 'scraper'

Encoding.default_external = "UTF-8"

class ParserTests < Minitest::Test
    def test_get_results_from_html
        html = File.read("fake.html")
        cars = Scraper.get_results_from_html(html)
        actual1 = {:name => cars.first[:name], :price => cars.first[:price]}
        expected1 = {:name => "BMW X1", :price => "51 660"}
        actual2 = {:name => cars.last[:name], :price => cars.last[:price]}
        expected2 = {:name => "BMW X5 M Competition", :price => "499 000"}
        assert actual1 == expected1
        assert actual2 = expected2
    end
end

