require 'net/http'

class CurrencyRateUpdater
  def self.form_url(date)
    "https://www.cbr.ru/scripts/XML_daily.asp?date_req=#{date.strftime('%d/%m/%Y')}"
  end

  def self.update_for_date(date)
    url      = form_url(date)
    xml_data = fetch_xml_data(url)

    unless xml_data.is_a?(Nokogiri::XML::Document)
      Rails.logger.error("Broken XML given from #{url}")
      return
    end

    # TODO: need to refactor this part for easy expanding of the currencies list
    xml_data.xpath('//Valute[CharCode="USD" or CharCode="EUR"]').each do |valute|
      currency_code = valute.at('CharCode').text
      exchange_rate = valute.at('Value').text.sub(',', '.').to_f

      update_or_create_currency_rate(date, currency_code, exchange_rate)
    end
  end

  def self.fetch_xml_data(url)
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

  def self.update_or_create_currency_rate(date, currency_code, exchange_rate)
    currency_rate = CurrencyRate.find_or_initialize_by(date: date, currency_code: currency_code)

    return unless currency_rate.new_record? || currency_rate.exchange_rate != exchange_rate

    currency_rate.exchange_rate = exchange_rate
    currency_rate.save!
  end
end
