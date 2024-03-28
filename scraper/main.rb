require_relative 'presenter'
require_relative 'scraper'

cars = Scraper.get_cars
Presenter.create_pdf(cars)

