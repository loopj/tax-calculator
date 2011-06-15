#!/usr/bin/env ruby

require "common"

if ARGV.length < 1
  puts "Usage #{$0} gross_salary itemized_deductions"
  exit
end

def calculate_income_tax(gross_income, filing_status, itemized_deductions)
  federal_tax = calculate_tax_layer("federal_income_tax", filing_status, gross_income, itemized_deductions)
  state_tax = calculate_tax_layer("state_income_tax_ca", filing_status, gross_income, itemized_deductions)
  social_security = calculate_tax_layer("social_security", filing_status, gross_income, itemized_deductions)
  medicare = calculate_tax_layer("medicare", filing_status, gross_income, itemized_deductions)
  net_income = gross_income - federal_tax - state_tax - social_security - medicare

  puts "Gross Income: $#{gross_income}"
  puts "Federal Tax: $#{federal_tax}"
  puts "CA Tax: $#{state_tax}"
  puts "Social Security: $#{social_security}"
  puts "Medicare: $#{medicare}"
  puts "Net Income: $#{net_income} (#{net_income/gross_income*100}% of gross)"
end

calculate_income_tax(ARGV[0].to_i, ARGV[1], ARGV[1].to_i)