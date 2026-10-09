# frozen_string_literal: true

module PeppolCodeLists
  # A single entry of a code list. +description+ is nil when the list does not provide one.
  Code = Data.define(:id, :name, :description)
end
