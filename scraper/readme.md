### Prerequisites

install wkhtmltopdf: visit https://github.com/pdfkit/pdfkit/wiki/Installing-WKHTMLTOPDF for details

wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt --fix-broken install
dpkg -i /home/hosting/scraper/wkhtmltox_0.12.6.1-2.jammy_amd64.deb 

### Run the scrapper

    ruby main.rb

