module Scraper
  class LoadDocument
    def initialize(url:)
      @url = url
    end

    # settings -> compress: true, expires_in: 1.hour

    def call
      document = Rails.cache.fetch("#{url}") do
        load_html_with_selenium
      end

      Nokogiri::HTML(document)
    end
  
    private
  
    attr_reader :url
  
    def load_html_with_selenium
      driver = Selenium::WebDriver.for :chrome, options: selenium_options

      driver.get url

      html = driver.page_source

      driver.quit

      html
    end

    def selenium_options(headless: false)
      options = Selenium::WebDriver::Chrome::Options.new

      return options unless headless

      options.add_argument('--headless')
      options.add_argument("start-maximized")
      options.add_argument("--disable-blink-features=AutomationControlled")
      options.add_argument("--disable-extensions")
      options.add_argument("--disable-web-security")
      options.add_argument("--disable-dev-shm-usage")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-gpu")
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.53 Safari/537.36")
    
      options
    end
  end
end
