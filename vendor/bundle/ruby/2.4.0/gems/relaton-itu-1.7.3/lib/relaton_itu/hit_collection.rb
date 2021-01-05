# frozen_string_literal: true

require "relaton_itu/hit"
require "addressable/uri"
require "net/http"

module RelatonItu
  # Page of hit collection.
  class HitCollection < RelatonBib::HitCollection
    DOMAIN = "https://www.itu.int"

    # @return [TrueClass, FalseClass]
    attr_reader :gi_imp

    # @param ref [String]
    # @param year [String]
    def initialize(ref, year = nil)
      text = ref.sub /(?<=\.)Imp\s?(?=\d)/, ""
      super text, year
      @gi_imp = /\.Imp\d/.match?(ref)
      uri = URI "#{DOMAIN}/net4/ITU-T/search/GlobalSearch/Search"
      data = { json: params.to_json }
      resp = Net::HTTP.post(uri, data.to_json,
                            "Content-Type" => "application/json")
      @array = hits JSON.parse(resp.body)
    end

    private

    # @return [String]
    def group
      @group ||= if %r{OB|Operational Bulletin}.match? text then "Publications"
                 else "Recommendations"
                 end
    end

    # rubocop:disable Metrics/MethodLength

    # @return [Hash]
    def params
      {
        "Input" => text,
        "Start" => 0,
        "Rows" => 10,
        "SortBy" => "RELEVANCE",
        "ExactPhrase" => false,
        "CollectionName" => "General",
        "CollectionGroup" => group,
        "Sector" => "t",
        "Criterias" => [{
          "Name" => "Search in",
          "Criterias" => [
            {
              "Selected" => false,
              "Value" => "",
              "Label" => "Name",
              "Target" => "\\/name_s",
              "TypeName" => "CHECKBOX",
              "GetCriteriaType" => 0,
            },
            {
              "Selected" => false,
              "Value" => "",
              "Label" => "Short description",
              "Target" => "\\/short_description_s",
              "TypeName" => "CHECKBOX",
              "GetCriteriaType" => 0,
            },
            {
              "Selected" => false,
              "Value" => "",
              "Label" => "File content",
              "Target" => "\\/file",
              "TypeName" => "CHECKBOX",
              "GetCriteriaType" => 0,
            },
          ],
          "ShowCheckbox" => true,
          "Selected" => false,
        }],
        "Topics" => "",
        "ClientData" => {},
        "Language" => "en",
        "SearchType" => "All",
      }
    end
    # rubocop:enable Metrics/MethodLength

    # @param data [Hash]
    # @return [Array<RelatonItu::Hit>]
    def hits(data)
      data["results"].map do |h|
        code  = h["Media"]["Name"]
        title = h["Title"]
        url   = h["Redirection"]
        type  = group.downcase[0...-1]
        Hit.new({ code: code, title: title, url: url, type: type }, self)
      end
    end
  end
end
