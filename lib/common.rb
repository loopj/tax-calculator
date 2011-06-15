#!/usr/bin/env ruby
require "yaml"

RATES = Dir["rates/*.yml"].inject({}) {|hash, filename| hash.merge!(YAML.load(File.read(filename))); hash }

def calculate_taxable_income(tax_type, filing_status, gross_income, itemized_deductions = 0)
  taxable_income = gross_income

  if RATES[tax_type] && RATES[tax_type][filing_status]
    # Remove best deduction from taxable income
    standard_deduction = RATES[tax_type][filing_status]["standard_deduction"]
    taxable_income -= [standard_deduction, itemized_deductions].max if standard_deduction

    # Remove personal exemption from taxable income
    personal_exemption = RATES[tax_type][filing_status]["personal_exemption"]
    taxable_income -= (personal_exemption || 0) if personal_exemption
  end

  return [taxable_income, 0].max
end

def calculate_tax_layer(tax_type, filing_status, gross_income, itemized_deductions = 0)
  # Get the appropriate tax rates
  rates = nil
  raise "No such tax type #{tax_type}" if RATES[tax_type].nil?
  if !RATES[tax_type]["rates"].nil?
    rates = RATES[tax_type]["rates"]
  elsif !RATES[tax_type][filing_status].nil? && !RATES[tax_type][filing_status]["rates"].nil?
    rates = RATES[tax_type][filing_status]["rates"]
  else
    raise "Couldnt find tax rates for tax type #{tax_type} and filing status #{filing_status}"
  end

  # Calculate the taxable income
  taxable_income = calculate_taxable_income(tax_type, filing_status, gross_income, itemized_deductions)

  # Set up the counters/temps
  total_tax = 0
  previous_threshold = 0

  # Apply tax from each applicable bracket
  rates.each do |bracket|
    # Add on the tax from this bracket
    total_tax += bracket["rate"] * ([bracket["limit"], taxable_income].compact.min - previous_threshold)

    # Store the last threshold
    previous_threshold = bracket["limit"]

    # Stop applying tax brackets if this threshold was above the taxable income
    break if bracket["limit"] && bracket["limit"] > taxable_income
  end

  return total_tax
end