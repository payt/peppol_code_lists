# frozen_string_literal: true

require_relative "lib/peppol_code_lists/version"

Gem::Specification.new do |spec|
  spec.name        = "peppol_code_lists"
  spec.version     = PeppolCodeLists::VERSION
  spec.authors     = ["Bob van Oorschot"]
  spec.email       = ["b.vanoorschot@paytsoftware.com"]
  spec.homepage    = "https://github.com/payt/peppol_code_lists"
  spec.summary     = "Peppol BIS Billing 3.0 code lists (UNECE Rec 20, EAS, ICD, UNCL, ...) for lookup and validation."
  spec.description = "Ships the code lists published by OpenPEPPOL for Peppol BIS Billing 3.0 as data, " \
                     "with a small API to look up and validate codes. No runtime dependencies."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "data/*.json", "MIT-LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
end
