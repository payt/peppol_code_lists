# frozen_string_literal: true

require "active_model"

RSpec.describe PeppolCodeValidator do
  def model_with(**validation)
    Class.new do
      include ActiveModel::Validations

      attr_accessor :unit_code

      def self.name = "InvoiceLine"

      validates :unit_code, **validation
    end
  end

  def errors_for(model, value)
    record = model.new
    record.unit_code = value
    record.validate
    record.errors
  end

  describe "with the list as shorthand" do
    let(:model) { model_with(peppol_code: :units_of_measure) }

    it "accepts codes in the list" do
      expect(errors_for(model, "C62")).to be_empty
    end

    ["c62", "piece", "", nil].each do |value|
      it "rejects #{value.inspect} with an inclusion error" do
        errors = errors_for(model, value)

        expect(errors.details[:unit_code]).to eq([{ error: :inclusion, value: }])
        expect(errors.full_messages).to eq(["Unit code is not included in the list"])
      end
    end
  end

  describe "with options" do
    let(:model) { model_with(peppol_code: { list: :units_of_measure, allow_nil: true, message: "is not a unit" }) }

    it "honours allow_nil" do
      expect(errors_for(model, nil)).to be_empty
    end

    it "uses a custom message" do
      expect(errors_for(model, "piece").full_messages).to eq(["Unit code is not a unit"])
    end
  end

  it "requires a code list" do
    expect { model_with(peppol_code: true) }.to raise_error(ArgumentError, /Pass the code list/)
  end

  it "rejects unknown code lists when the model is defined" do
    expect { model_with(peppol_code: :nope) }.to raise_error(PeppolCodeLists::UnknownList)
  end
end
