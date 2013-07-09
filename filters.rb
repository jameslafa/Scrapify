# Filter a string by removing a list of string
# Params :
#  - string_to_clean : the original string that need to be cleaned
#  - list_of_string_to_remove : array of string that will be removed from the string_to_clean
#  - strip : will remove any surrounding space if true (default)
def filter_string(string_to_clean = "", list_of_string_to_remove = [], strip = true)
  list_of_string_to_remove.each do |string_to_remove|
    string_to_clean.gsub!(string_to_remove, "")
  end

  string_to_clean.strip! if strip
  return string_to_clean
end

# Remove every characters that doesn't belong to the number
# Params :
#  - string_to_clean : the original string that need to be cleaned
#  - decimal_delimiter : define the decimal parameter "." (default) or probably ","
def filter_non_number_characters(string_to_clean, decimal_delimiter = ".")
  clean_regex = Regexp.new("[^\\d\\#{decimal_delimiter}]")
  return string_to_clean.gsub(clean_regex, "")
end

# Transform a percentage (string) to a float (where 100% == 1)
# Params :
#  - percentage_string : the original string where the percentage value will be extracted
#  - percentage_divider : the divider. By default it's 100 for percentage, but may be 1000 or 100000
def percentage_to_float(percentage_string, percentage_divider = 100, decimal_delimiter = ".")
  string_value = filter_non_number_characters(percentage_string, decimal_delimiter)
  value = string_value.to_f / percentage_divider
  return value
end