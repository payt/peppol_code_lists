# frozen_string_literal: true

require "json"
require "open-uri"
require "rexml/document"

require "peppol_code_lists"

module PeppolCodeLists
  # Development tool: converts the OpenPEPPOL code list XML files into the JSON files shipped in data/.
  # Not part of the packaged gem.
  class Generator
    REPOSITORY = "OpenPEPPOL/peppol-bis-invoice-3"
    NAMESPACE = { "c" => "urn:fdc:difi.no:2017:vefa:structure:CodeList-1" }.freeze

    def self.source_url(tag, file)
      "https://raw.githubusercontent.com/#{REPOSITORY}/#{tag}/structure/codelist/#{file}.xml"
    end

    def initialize(tag:, data_dir: DATA_DIR, fetcher: ->(url) { URI.parse(url).open(&:read) })
      @tag = tag
      @data_dir = data_dir
      @fetcher = fetcher
    end

    def run
      LISTS.map do |key, file|
        url = self.class.source_url(@tag, file)
        path = File.join(@data_dir, "#{key}.json")
        File.write(path, "#{JSON.pretty_generate(convert(@fetcher.call(url), source: url))}\n")
        path
      end
    end

    def convert(xml, source:)
      root = REXML::Document.new(xml).root

      {
        "identifier" => text(root, "c:Identifier"),
        "title" => text(root, "c:Title"),
        "version" => text(root, "c:Version"),
        "source" => source,
        "codes" => REXML::XPath.match(root, "c:Code", NAMESPACE).map do |code|
          { "id" => text(code, "c:Id"), "name" => text(code, "c:Name"), "description" => text(code, "c:Description") }
        end
      }
    end

    private

    def text(node, path)
      value = REXML::XPath.first(node, path, NAMESPACE)&.text
      value&.gsub(/\s+/, " ")&.strip
    end
  end
end
