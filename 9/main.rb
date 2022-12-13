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

def update_tail!(tail, head)
    dx = head.x - tail.x
    dy = head.y - tail.y
    if dx.abs <= 1 && dy.abs <= 1
        # touching, do nothing
    else # works if we only have to move 1 pixel at a time
        tail.x += sign(dx)
        tail.y += sign(dy)
    end
end

def run_command!(cmd, head, tail)
    # run the command and see where the tail goes through

    tail_pos = []

    while cmd.steps > 0
        move_dir!(cmd.dir, head)
        update_tail!(tail,head)    
        tail_pos.push(tail.dup) 
        cmd.steps-=1
    end    
    tail_pos
end

def sign(x) x <=> 0 end
def repr_cmd(cmd) "#{cmd.dir} #{cmd.steps}" end
def repr_pos(pos) "(#{pos.x},#{pos.y})" end

head = Pos.new(0,0)
tail = Pos.new(0,0)

path = cmds.map {|cmd|
    # puts repr_cmd(cmd)
    # puts repr_pos(head)
    # puts tails.map{ |t| repr_pos(t) }.join(" ")}
    run_command!(cmd, head, tail)
}.flatten

ans1 = path.uniq.length
ans2 = "TODO"

puts "#{ans1},#{ans2}"
