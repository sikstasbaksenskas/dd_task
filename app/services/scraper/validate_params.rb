module Scraper
  class ValidateParams
    module ErrorMessages
      URL = 'URL was not provided!'
      FIELDS = 'FIELDS were not provided!'
      META_NOT_ARRAY = "'meta' attribute should be an array!"
    end

    def initialize(url:, fields:)
      @url = url
      @fields = fields
    end
  
    def call
      @response = OpenStruct.new(errors: [], success: true)
  
      validate_params
  
      @response.success = @response.errors.empty?
  
      @response
    end
  
    def validate_params
      validate_url
      validate_fields
      validate_meta_tags
    end
  
    def validate_url
      @response.errors << ErrorMessages::URL if url.blank?
    end
  
    def validate_fields
      @response.errors <<  ErrorMessages::FIELDS if fields.blank?
    end
  
    def validate_meta_tags
      return if fields.blank? || fields['meta'].blank?
  
      @response.errors << ErrorMessages::META_NOT_ARRAY unless fields['meta'].is_a?(Array)
    end
  
    private
  
    attr_reader :url, :fields
  end  
end
