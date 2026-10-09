# frozen_string_literal: true

require "active_model"
require "peppol_code_lists"

# Validates that an attribute holds a code of a Peppol code list:
#
#   validates :unit_code, peppol_code: :units_of_measure
#   validates :unit_code, peppol_code: { list: :units_of_measure, allow_nil: true, message: "is not a unit" }
#
# Invalid values get the standard +:inclusion+ error ("is not included in the list").
class PeppolCodeValidator < ActiveModel::EachValidator
  def check_validity!
    raise ArgumentError, "Pass the code list to validate against, e.g. peppol_code: :units_of_measure" unless list_key

    code_list
  end

  def validate_each(record, attribute, value)
    return if code_list.valid?(value)

    record.errors.add(attribute, :inclusion, **options.except(:list, :with), value:)
  end

  private

  def list_key
    options[:list] || options[:with]
  end

  def code_list
    PeppolCodeLists[list_key]
  end
end
