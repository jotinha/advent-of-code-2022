Cmd = Struct.new(:dir, :steps)

cmds = File.readlines("test").map { |line|
    x  = line.strip.split
    Cmd.new(x[0].to_sym, x[1].to_i)
}
puts cmds
