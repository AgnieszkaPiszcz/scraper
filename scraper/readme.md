### Prerequisites

Required for generating pdsf.

install nvm and node 

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.bashrc
    nv install node

install chromium:

    sudo apt-get install chromium-browser

install missing dependecies;

    sudo apt install libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev
    sudo apt-get install libasound2

install puppeteer:

    npm install puppeteer

### Run the scrapper

    ruby scraper.rb

