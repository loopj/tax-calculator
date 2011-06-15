#!/usr/bin/env ruby

require "common"

if ARGV.length < 1
  puts "Usage #{$0} gross_salary itemized_deductions number_of_shares exercise_price fair_market_value_at_exercise"
  exit
end

def calculate_exercise_spread(number_of_shares, exercise_price, fair_market_value_at_exercise)
  number_of_shares * (fair_market_value_at_exercise - exercise_price)
end

def calculate_amt(gross_income, itemized_deductions, number_of_shares, exercise_price, fair_market_value_at_exercise)
  regular_taxable_income = calculate_taxable_income("federal_income_tax", "married_filing_jointly", gross_income, itemized_deductions)
  iso_exercise_spread = calculate_exercise_spread(number_of_shares, exercise_price, fair_market_value_at_exercise)
  amt_taxable_income = regular_taxable_income + iso_exercise_spread

  tentative_minimum_tax = calculate_tax_layer("federal_amt", "married_filing_jointly", amt_taxable_income, itemized_deductions)
  federal_income_tax = calculate_tax_layer("federal_income_tax", "married_filing_jointly", gross_income, itemized_deductions)

  amt = tentative_minimum_tax - federal_income_tax

  puts "Regular Taxable Income: $#{regular_taxable_income} (Gross income less deductions and personal exemption)"
  puts "Federal Income Tax: $#{federal_income_tax}"
  puts "ISO Exercise Spread: $#{iso_exercise_spread} (Number of Shares * (Fair Market Value at Exercise - Exercise Price))"
  puts "AMT Taxable Income: $#{amt_taxable_income} (Regular Taxable Income + ISO Exercise Spread)"
  puts "Tentative Minimum Tax: $#{tentative_minimum_tax} ((AMT Taxable Income - AMT Personal Exemption) * AMT Rates)"
  puts
  puts "AMT: $#{amt} (Tentative Minimum Tax - Federal Income Tax)"

  if amt > federal_income_tax
    puts "AMT applies (AMT is more than Federal Income Tax)"
  else
    puts "AMT does not apply (AMT is less than Federal Income Tax)"
  end
end

calculate_amt(*ARGV.map {|arg| arg.to_f})