# PeppolCodeLists

The code lists of [Peppol BIS Billing 3.0](https://docs.peppol.eu/poacc/billing/3.0/codelist/), such as
[UNECE Recommendation 20](https://docs.peppol.eu/poacc/billing/3.0/codelist/UNECERec20/) units of measure, as data
with a small lookup and validation API. No runtime dependencies.

## Installation

```ruby
gem "peppol_code_lists", github: "payt/peppol_code_lists"
```

## Usage

```ruby
require "peppol_code_lists"

PeppolCodeLists.units_of_measure.valid?("C62")  # => true
PeppolCodeLists.units_of_measure.valid?("c62")  # => false, matching is exact and case-sensitive
PeppolCodeLists.units_of_measure.find("HUR")    # => #<data PeppolCodeLists::Code id="HUR", name="hour", description=nil>
PeppolCodeLists.units_of_measure.find("FOO")    # => nil
PeppolCodeLists.units_of_measure.fetch("FOO")   # raises PeppolCodeLists::UnknownCode
PeppolCodeLists.units_of_measure.version        # => "Revision 11e"
PeppolCodeLists.units_of_measure.identifier     # => "UNECERec20"

PeppolCodeLists[:electronic_address_schemes].valid?("0106") # generic access by key
PeppolCodeLists.keys # => [:units_of_measure, :currencies, ...]
```

Lists are loaded lazily on first access and frozen.

Each list is available under a descriptive name. `identifier` and `title` hold the official Peppol names.

| Method | Peppol code list |
| --- | --- |
| `units_of_measure` | UNECERec20: Recommendation 20, including Recommendation 21 codes prefixed with X |
| `currencies` | ISO4217: currency codes |
| `countries` | ISO3166: alpha-2 country codes |
| `mime_types` | MimeCode: MIME types allowed for attachments |
| `sepa_indicators` | SEPA indicator |
| `invoice_types` | UNCL1001-inv: invoice type codes |
| `credit_note_types` | UNCL1001-cn: credit note type codes |
| `invoiced_object_identifier_schemes` | UNCL1153: invoiced object identifier schemes |
| `vat_date_codes` | UNCL2005: VAT date codes |
| `payment_means` | UNCL4461: payment means codes |
| `allowance_reasons` | UNCL5189: allowance reason codes |
| `tax_categories` | UNCL5305: duty or tax or fee category codes |
| `item_classifications` | UNCL7143: item type identification codes |
| `charge_reasons` | UNCL7161: charge reason codes |
| `vat_exemption_reasons` | VATEX: VAT exemption reason codes |
| `electronic_address_schemes` | EAS: electronic address schemes |
| `identifier_schemes` | ICD: ISO 6523 identifier schemes |

## ActiveModel validation

`PeppolCodeValidator` validates an attribute against any of the lists. It is loaded on first use, so the gem does not
depend on ActiveModel; apps that use it already have it.

```ruby
class InvoiceLine < ApplicationRecord
  validates :unit_code, peppol_code: :units_of_measure
  validates :payment_means_code, peppol_code: { list: :payment_means, allow_nil: true }
end
```

Invalid values get the standard `:inclusion` error ("is not included in the list"), so existing translations apply.
`message:`, `allow_nil:`, `allow_blank:`, `if:` and the other common validation options work as usual.

## Updating the code lists

The JSON files in `data/` are generated from the XML code lists in
[OpenPEPPOL/peppol-bis-invoice-3](https://github.com/OpenPEPPOL/peppol-bis-invoice-3/tree/master/structure/codelist).
To pick up a new Peppol release:

```sh
bundle exec rake "code_lists:update[v3.0.21]"
git diff data/
```

Review the diff, bump the version and add a CHANGELOG entry.

## Development

```sh
bundle install
bundle exec rake   # rspec (100% line and branch coverage) and rubocop
```

## License

MIT, see [MIT-LICENSE](MIT-LICENSE).
