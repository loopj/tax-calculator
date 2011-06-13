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

def standard_deduction(name, deduction)
  DEDUCTIONS[name] ||= []
  DEDUCTIONS[name] << deduction
end

def personal_exemption(name, exemption)
  EXEMPTIONS[name] ||= []
  EXEMPTIONS[name] << exemption
end

# Federal tax
rate :federal_married_joint, 0.10, 17000
rate :federal_married_joint, 0.15, 69000
rate :federal_married_joint, 0.25, 139350
rate :federal_married_joint, 0.28, 212300
rate :federal_married_joint, 0.33, 379150
rate :federal_married_joint, 0.35
standard_deduction :federal_married_joint, 11600
personal_exemption :federal_married_joint, 7400

# CA tax
rate :ca_married_joint, 0.011, 14248
rate :ca_married_joint, 0.022, 33780
rate :ca_married_joint, 0.044, 53314
rate :ca_married_joint, 0.066, 74010
rate :ca_married_joint, 0.088, 93532
rate :ca_married_joint, 0.1023, 1000000
rate :ca_married_joint, 0.1133
standard_deduction :ca_married_joint, 7340
personal_exemption :ca_married_joint, 182

# Social security
rate :social_security_married_joint, 0.045, 106800 # TODO: Is this accurate for married

# Medicare
rate :medicare, 0.0145

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