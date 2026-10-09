# frozen_string_literal: true

RSpec.describe PeppolCodeLists::CodeList do
  subject(:list) do
    described_class.from_hash(:test, {
      "identifier" => "TEST", "title" => "Test list", "version" => "1.0", "source" => "https://example.com/test.xml",
      "codes" => [
        { "id" => "C62", "name" => "one", "description" => "A unit of count." },
        { "id" => "ZZ", "name" => "mutually defined", "description" => nil }
      ]
    })
  end

  let(:one) { PeppolCodeLists::Code.new(id: "C62", name: "one", description: "A unit of count.") }

  it "exposes the metadata" do
    expect(list).to have_attributes(key: :test, identifier: "TEST", title: "Test list", version: "1.0",
                                    source: "https://example.com/test.xml", size: 2, ids: ["C62", "ZZ"])
  end

  describe "#valid?" do
    it "checks membership" do
      expect(list.valid?("C62")).to be(true)
      expect(list.include?("ZZ")).to be(true)
      expect(list.valid?("XX")).to be(false)
    end
  end

  describe "#find" do
    it "returns the code or nil" do
      expect(list.find("C62")).to eq(one)
      expect(list["ZZ"].description).to be_nil
      expect(list.find("XX")).to be_nil
    end
  end

  describe "#fetch" do
    it "returns the code" do
      expect(list.fetch("C62")).to eq(one)
    end

    it "raises for an unknown code" do
      expect { list.fetch("XX") }.to raise_error(PeppolCodeLists::UnknownCode, "\"XX\" is not a code in TEST")
    end
  end

  describe "#inspect" do
    it "summarises the list" do
      expect(list.inspect).to eq("#<PeppolCodeLists::CodeList test (TEST 1.0, 2 codes)>")
    end

    it "omits a missing version" do
      list = described_class.new(key: :test, identifier: "TEST", title: "T", version: nil, source: "s", codes: [])

      expect(list.inspect).to eq("#<PeppolCodeLists::CodeList test (TEST, 0 codes)>")
    end
  end
end
