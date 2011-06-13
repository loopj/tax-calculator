#!/usr/bin/env ruby

if ARGV.length != 1
  puts "Usage ./tax.rb gross_salary"
  exit
end

RATES = {}
DEDUCTIONS = {}
EXEMPTIONS = {}
def rate(name, rate, threshold=nil)
  RATES[name] ||= []
  RATES[name] << {
    :rate => rate,
    :threshold => threshold
  }
end

def deduction(name, deduction)
  DEDUCTIONS[name] ||= []
  DEDUCTIONS[name] << deduction
end

def exemption(name, exemption)
  EXEMPTIONS[name] ||= []
  EXEMPTIONS[name] << exemption
end

require 'rates/federal'
require 'rates/state_ca'
require 'rates/medicare'
require 'rates/social_security'

def calculate_tax_part(status, salary)
  # Adjust salary for deductions and exemptions if any
  adjusted_salary = salary
  adjusted_salary -= DEDUCTIONS[status].inject(nil) {|sum,x| sum ? sum+x : x} if DEDUCTIONS[status]
  adjusted_salary -= EXEMPTIONS[status].inject(nil) {|sum,x| sum ? sum+x : x} if EXEMPTIONS[status]
  return 0 if adjusted_salary < 0

  total_tax = 0
  previous_threshold = 0
  RATES[status].each do |bracket|
    total_tax += bracket[:rate] * ([bracket[:threshold], adjusted_salary].compact.min - previous_threshold)

    break if bracket[:threshold] && bracket[:threshold] > adjusted_salary

    previous_threshold = bracket[:threshold]
  end

  total_tax
end

def calculate_tax(salary)
  federal_tax = calculate_tax_part(:federal_married_joint, salary)
  state_tax = calculate_tax_part(:ca_married_joint, salary)
  social_security = calculate_tax_part(:social_security_married_joint, salary)
  medicare = calculate_tax_part(:medicare, salary)
  net_salary = salary - federal_tax - state_tax - social_security - medicare

  puts "Gross Salary: $#{salary}"
  puts "Federal Tax: $#{federal_tax}"
  puts "CA Tax: $#{state_tax}"
  puts "Social Security: $#{social_security}"
  puts "Medicare: $#{medicare}"
  puts "Net Salary: $#{net_salary} (#{net_salary/salary*100}% of gross)"
end

calculate_tax(ARGV.first.to_i)