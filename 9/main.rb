Cmd = Struct.new(:dir, :steps)
Pos = Struct.new(:x, :y)

cmds = File.readlines("test").map { |line|
    x  = line.strip.split
    Cmd.new(x[0].to_sym, x[1].to_i)
}

head = tail = Pos.new(0,0)

def move!(cmd, pos)
    while cmd.steps > 0 do
        case cmd.dir
            when :R
                pos.x += 1
            when :L
                pos.x -= 1
            when :U
                pos.y += 1
            when :D
                pos.y -= 1
        end
        cmd.steps-=1
    end
end

cmds.each do |cmd| 
    puts cmd
    move!(cmd, head)
    puts head
end

