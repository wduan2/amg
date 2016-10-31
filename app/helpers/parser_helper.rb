class ParserHelper

  # input: am -u label new_name -p label new_password --debug
  #
  # output: am -u label,new_name -p label,new_password --debug
  #
  def self.parse(args)
    cmd = nil
    cmds_params = {}

    args.each do |arg|

      if arg =~ /\A[-]+/
        cmd = arg
        cmds_params[cmd] = []
      else
        cmds_params[cmd] << arg
      end
    end

    args.clear
    index = 0
    cmds_params.each do |k, v|
      args[index] = k
      index = index + 1
      unless v.empty?
        args[index] = v.join(',')
        index = index + 1
      end
    end
  end
end
