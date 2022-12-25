Cmd = Struct.new(:dir, :steps)
Pos = Struct.new(:x, :y)

cmds = File.readlines("input").map { |line|
    x  = line.strip.split
    Cmd.new(x[0].to_sym, x[1].to_i)
}

def move!(pos, x, y)
    pos.x += x
    pos.y += y
end

def move_dir!(dir, pos)
    case dir
        when :R
            move!(pos,1,0)
        when :L
            move!(pos,-1,0)
        when :U
            move!(pos,0,1) 
        when :D
            move!(pos,0,-1)
    end 
end

def pull!(tail, head)
    dx = head.x - tail.x
    dy = head.y - tail.y
    if dx.abs <= 1 && dy.abs <= 1
        # touching, do nothing
    else # works if we only have to move 1 pixel at a time
        tail.x += sign(dx)
        tail.y += sign(dy)
    end
end

def run_command!(cmd, knots)
    # run the command and see where the tail goes through
    (1..cmd.steps).map do |_|
        move_dir!(cmd.dir, knots[0])
        knots.each_cons(2) { |k1,k2| pull!(k2,k1) }
        knots[-1].dup 
    end 
end

def sign(x) x <=> 0 end

def track_tail(cmds, n_knots)
    knots = (1..n_knots).map{|x| Pos.new(0,0) }
    cmds.map {|cmd| run_command!(cmd, knots)}.flatten
end

ans1 = track_tail(cmds, 2).uniq.length
ans2 = track_tail(cmds, 10).uniq.length

puts "#{ans1},#{ans2}"
