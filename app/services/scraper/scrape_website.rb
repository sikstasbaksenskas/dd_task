module Scraper
  class ScrapeWebsite
    def initialize(url:, fields:)
      @url = url
      @fields = fields
      @scraped_data = {}
    end
  
    def call
      scrape_meta_tags if fields.has_key?('meta')
  
      scrape_fields
  
      @scraped_data
    end
  
    private
  
    attr_reader :url, :fields
  
    def document
      @document ||= LoadDocument.new(url: url).call
    end
  
    def scrape_fields
      fields.each do |key, value|
        @scraped_data[key] = scrape_field(value)
      end
    end
  
    def scrape_field(selector)
      document.css(selector).text.strip
    end
  
    def scrape_meta_tags
      @scraped_data['meta'] = {}
  
      fields.delete('meta').each do |tag|
        @scraped_data['meta'][tag] = scrape_meta_tag(tag)
      end
    end
  
    def scrape_meta_tag(selector)
      tag = document.at_css("meta[name='#{selector}']")
  
      tag['content'] if tag
    end
  end
end
