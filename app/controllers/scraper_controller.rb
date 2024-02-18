class ScraperController < ApplicationController
  rescue_from Scraper::Errors::BadRequest, with: :bad_request

  before_action :validate_params, only: :scrape

  def scrape
    data = Scraper::ScrapeWebsite.new(url: scraper_params[:url], fields: scraper_params[:fields]).call

    render json: data
  end

  private

  def validate_params
    response = Scraper::ValidateParams.new(url: scraper_params[:url], fields: scraper_params[:fields]).call
  
    raise Scraper::Errors::BadRequest, response.errors unless response.success
  end

  def bad_request(exception)
    render json: exception.message, status: :bad_request
  end

  def scraper_params
    @scraper_params ||= params.require(:scraper).permit(:url, fields: {})
  end
end
