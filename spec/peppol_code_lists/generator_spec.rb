# frozen_string_literal: true

require "tmpdir"
require_relative "../../tools/generator"

RSpec.describe PeppolCodeLists::Generator do
  let(:xml) { File.read(File.expand_path("../fixtures/code_list.xml", __dir__)) }

  describe ".source_url" do
    it "points at the code list of the given tag" do
      expect(described_class.source_url("v3.0.20", "eas")).to eq(
        "https://raw.githubusercontent.com/OpenPEPPOL/peppol-bis-invoice-3/v3.0.20/structure/codelist/eas.xml"
      )
    end
  end

  describe "#convert" do
    it "converts the XML and normalises whitespace" do
      expect(described_class.new(tag: "t").convert(xml, source: "src")).to eq(
        "identifier" => "TEST", "title" => "Test list", "version" => "1.0", "source" => "src",
        "codes" => [
          { "id" => "C62", "name" => "one", "description" => "A unit of count defining the number of pieces." },
          { "id" => "ZZ", "name" => "mutually defined", "description" => nil }
        ]
      )
    end
  end

  describe "#run" do
    it "writes a JSON file per list that the gem can load" do
      Dir.mktmpdir do |dir|
        urls = []
        paths = described_class.new(tag: "t", data_dir: dir, fetcher: ->(url) { (urls << url) && xml }).run

        expect(paths.map { |path| File.basename(path, ".json").to_sym }).to eq(PeppolCodeLists.keys)
        expect(urls.first).to end_with("/t/structure/codelist/UNECERec20-11e.xml")

        data = JSON.parse(File.read(File.join(dir, "electronic_address_schemes.json")))
        expect(PeppolCodeLists::CodeList.from_hash(:electronic_address_schemes, data).ids).to eq(["C62", "ZZ"])
      end
    end
  end
end
