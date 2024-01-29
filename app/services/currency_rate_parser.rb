# frozen_string_literal: true

require 'net/http'

class CurrencyRateParser
  def initialize(date)
    @date = date
  end

  def fetch_xml_data
    url      = form_url
    uri      = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      begin
        Nokogiri::XML(response.body)
      rescue Nokogiri::XML::SyntaxError => e
        Rails.logger.error("Failed to parse XML from #{url}: #{e.message}")
        nil
      end
    else
      Rails.logger.error("Failed to fetch data from #{url}: HTTP Error #{response.code}")
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Failed to fetch data from #{url}: #{e.message}")
    nil
  end

  private

  def form_url
    format(Rails.application.config.cbr_currency_settings['api'], date: @date.strftime('%d/%m/%Y'))
  end
end
