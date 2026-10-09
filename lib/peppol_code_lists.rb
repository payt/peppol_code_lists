# frozen_string_literal: true

require "json"

require_relative "peppol_code_lists/version"
require_relative "peppol_code_lists/code"
require_relative "peppol_code_lists/code_list"

# Code lists of Peppol BIS Billing 3.0, as published by OpenPEPPOL.
#
#   PeppolCodeLists.units_of_measure.valid?("C62")                    # => true
#   PeppolCodeLists[:electronic_address_schemes].find("0106").name # => "Association of Chambers of Commerce and ..."
module PeppolCodeLists
  class Error < StandardError; end
  class UnknownList < Error; end
  class UnknownCode < Error; end

  DATA_DIR = File.expand_path("../data", __dir__)

  # Descriptive key => upstream file name (without .xml) in OpenPEPPOL/peppol-bis-invoice-3/structure/codelist.
  LISTS = {
    units_of_measure: "UNECERec20-11e",
    currencies: "ISO4217_2015",
    countries: "ISO3166-1_Alpha2",
    mime_types: "MimeCode",
    sepa_indicators: "SEPA",
    invoice_types: "UNCL1001-inv",
    credit_note_types: "UNCL1001-cn",
    invoiced_object_identifier_schemes: "UNCL1153",
    vat_date_codes: "UNCL2005",
    payment_means: "UNCL4461",
    allowance_reasons: "UNCL5189",
    tax_categories: "UNCL5305",
    item_classifications: "UNCL7143",
    charge_reasons: "UNCL7161",
    vat_exemption_reasons: "VATEX",
    electronic_address_schemes: "eas",
    identifier_schemes: "icd"
  }.freeze

  @lists = {}
  @mutex = Mutex.new

  class << self
    def keys
      LISTS.keys
    end

    def [](key)
      key = key.to_sym
      raise UnknownList, "Unknown code list #{key.inspect}, known lists: #{keys.join(", ")}" unless LISTS.key?(key)

      @lists[key] || @mutex.synchronize { @lists[key] ||= load(key) }
    end

    LISTS.each_key do |key|
      define_method(key) { self[key] }
    end

    private

    def load(key)
      CodeList.from_hash(key, JSON.parse(File.read(File.join(DATA_DIR, "#{key}.json"))))
    end
  end
end
