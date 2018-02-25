module Validator

  def next_i?(args, err)
    next_arg = args.shift
    return next_arg if next_arg && next_arg =~ /\A\d+\z/

    raise err
  end

  def next_n?(args, n, err)
    n = 1 if n < 1
    next_args = args.shift(n)
    raise err if next_args.size != n
    next_args.each { |arg| raise err if arg.nil? || arg == ' ' || arg.start_with?('-') }
    next_args
  end

  def next?(args, err)
    next_arg = args.shift
    raise err if next_arg.nil? || next_arg == ' ' || next_arg.start_with?('-')
    next_arg
  end
end
