# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Formatted string
  class FormattedString < LocalizedString
    FORMATS = %w[text/plain text/html application/docbook+xml
                 application/tei+xml text/x-asciidoc text/markdown
                 application/x-isodoc+xml].freeze

    # @return [String]
    attr_reader :format

    # @param content [String, Array<RelatonBib::LocalizedString>]
    # @param language [String, NilClass] language code Iso639
    # @param script [String, NilClass] script code Iso15924
    # @param format [String] the content type
    def initialize(content:, language: nil, script: nil, format: "text/plain")
      # if format && !FORMATS.include?(format)
      #   raise ArgumentError, %{Format "#{format}" is invalid.}
      # end

      super(content, language, script)
      @format = format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent["format"] = format if format
      super
    end

    # @return [Hash]
    def to_hash
      hash = super
      return hash unless format

      hash = { "content" => hash } unless hash.is_a? Hash
      hash["format"] = format
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of elements
    # @return [String]
    def to_asciibib(prefix = "", count = 1, has_attrs = false)
      has_attrs ||= !(format.nil? || format.empty?)
      pref = prefix.empty? ? prefix : prefix + "."
      # out = count > 1 ? "#{prefix}::\n" : ""
      out = super
      out += "#{pref}format:: #{format}\n" if format
      out
    end
  end
end
