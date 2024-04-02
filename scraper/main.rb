require_relative 'presenter'
require_relative 'scraper'

cars = Scraper.get_cars(4)
Presenter.create_pdf(cars)
Presenter.create_csv(cars)


