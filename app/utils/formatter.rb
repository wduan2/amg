module Formatter

  module_function

  # Format the result.
  #
  # @param result the sql query result
  # @return the result with formatted date
  def format(result)
    if result
      result.each do |row|
        row.keys.each do |key|
          format_date(row, key)
          format_nil(row, key)
        end
      end
    end
  end

  private_class_method

  # Format the date.
  #
  # @param hash the sql query result
  # @param key the key
  def format_date(hash, key)
    if hash[key].is_a? Date
      hash[key] = hash[key].strftime('%Y-%m-%d')
    end
  end

  # Format nil value.
  #
  # @param hash the sql query result
  # @param key the key
  def format_nil(hash, key)
    if hash[key].nil?
      hash[key] = 'N/A'
    end
  end
end
