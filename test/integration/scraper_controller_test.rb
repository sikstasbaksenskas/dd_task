require "minitest/autorun"
require 'mocha/minitest'

class ScraperControllerTest < ActionDispatch::IntegrationTest
  test "that meta tags are scraped correctly when params are valid" do
    stub_document_loader

    params = {
      url: "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
      fields: {
        meta: ["keywords", "twitter:image"]
      }
    }

    post scrape_path, params: params, as: :json

    response_body = JSON.parse(response.body)

    assert_response :success

    assert_equal(
      response_body,
      { 
        "meta"=> { 
          "keywords"=>"AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG",
          "twitter:image"=>"https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360"
        }
      }
    )
  end

  test "that fields are scraped correctly when params are valid" do
    stub_document_loader

    params = {
      url: "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
      fields: {
        price: ".price-box__price",
        rating_count: ".ratingCount",
        rating_value: ".ratingValue"
      }
    }

    post scrape_path, params: params, as: :json

    response_body = JSON.parse(response.body)

    assert_response :success

    assert_equal(
      response_body,
      {
        "price"=>"20 890,-",
        "rating_count"=>"7 hodnocení",
        "rating_value"=>"4,9"
      }
    )
  end

  test "that fields and meta tags are scraped when params are valid" do
    stub_document_loader

    params = {
      url: "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
      fields: {
        price: ".price-box__price",
        meta: ["keywords", "twitter:image"]
      }
    }

    post scrape_path, params: params, as: :json

    response_body = JSON.parse(response.body)

    assert_response :success

    assert_equal(
      response_body,
      { 
        "meta"=> { 
          "keywords"=>"AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG",
          "twitter:image"=>"https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360"
        },
        "price"=>"20 890,-"
      }
    )
  end

  test "that are returned when params are not valid" do
    params = {
      url: "",
      fields: ""
    }

    post scrape_path, params: params, as: :json

    response_body = JSON.parse(response.body)

    assert_response :bad_request

    assert_equal(
      response_body,
      ["URL was not provided!", "FIELDS were not provided!"]
    )
  end

  test "that error is returned if meta attribute is not an array" do
    params = {
      url: "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
      fields: {
        meta: "not_array"
      }
    }

    post scrape_path, params: params, as: :json

    response_body = JSON.parse(response.body)

    assert_response :bad_request

    assert_equal(
      response_body,
      ["'meta' attribute should be an array!"]
    )
  end

  private

  def stub_document_loader
    document = File.read(File.join(Rails.root, 'test', 'fixtures', 'files', 'test-html-for-scraping'))

    stub = Nokogiri::HTML(document)

    Scraper::LoadDocument.any_instance.expects(:call).returns(stub)
  end
end
