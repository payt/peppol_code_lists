# frozen_string_literal: true

RSpec.describe PeppolCodeLists do
  it "has a version number" do
    expect(PeppolCodeLists::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "does not load ActiveModel until the validator is used" do
    script = 'require "peppol_code_lists"; print defined?(ActiveModel).inspect'
    output = IO.popen([RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", script], &:read)

    expect(output).to eq("nil")
  end

  describe ".keys" do
    it "lists every code list" do
      expect(described_class.keys).to eq(PeppolCodeLists::LISTS.keys)
    end
  end

  describe ".[]" do
    it "returns the code list for a symbol or string key" do
      expect(described_class[:electronic_address_schemes]).to be(described_class["electronic_address_schemes"])
    end

    it "raises for an unknown list" do
      expect { described_class[:nope] }.to raise_error(PeppolCodeLists::UnknownList, /Unknown code list :nope/)
    end

    it "loads each list only once when accessed concurrently" do
      described_class.instance_variable_get(:@lists).delete(:vat_date_codes)

      lists = Array.new(10) { Thread.new { described_class[:vat_date_codes] } }.map(&:value)

      expect(lists.uniq(&:object_id).size).to eq(1)
    end
  end

  PeppolCodeLists::LISTS.each_key do |key|
    describe ".#{key}" do
      subject(:list) { described_class.public_send(key) }

      it "loads a frozen, non-empty list with unique codes" do
        expect(list).to be_frozen
        expect(list.codes).to be_frozen
        expect(list.size).to be_positive
        expect(list.ids.uniq.size).to eq(list.size)
        expect(list.identifier).not_to be_empty
      end
    end
  end

  describe ".units_of_measure" do
    subject(:list) { described_class.units_of_measure }

    ["C62", "HUR", "KGM", "ZZ", "XBX"].each do |code|
      it "accepts #{code}" do
        expect(list.valid?(code)).to be(true)
      end
    end

    ["c62", "", " C62", "FOO", nil, 62].each do |code|
      it "rejects #{code.inspect}" do
        expect(list.valid?(code)).to be(false)
      end
    end

    it "knows its version" do
      expect(list.version).to eq("Revision 11e")
    end
  end
end
