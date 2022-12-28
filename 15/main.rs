use std::fs;
use std::collections::HashSet;
use std::iter::FromIterator;
use std::ops::Range;
use std::cmp::min;
use std::cmp::max;

#[derive(Eq, Hash, PartialEq)]
struct Point {x:i32,y:i32}

struct Sensor {pos: Point, beacon: Point, coverage: i32 } 

fn parse(line: &str) -> Sensor {

    let ns : Vec<i32> = line
        .split(['=',',',':'])
        .map(|x| x.parse::<i32>())
        .filter(|x| x.is_ok())
        .map(|x| x.unwrap()).
        collect();
    let s = Point {x: ns[0], y: ns[1] };
    let b = Point {x: ns[2], y: ns[3] };
    let d = dist(&s,&b);
    Sensor {pos: s, beacon: b, coverage: d } 
}


fn split_lines(content: &str) -> Vec<&str> {
    content 
        .split('\n')
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .collect()
}

fn dist(a: &Point, b: &Point) -> i32 { (a.x-b.x).abs() + (a.y-b.y).abs() }

fn is_covered(p: &Point, sensors: &Vec<Sensor>) -> bool {
    sensors.iter().any(|s| dist(p,&s.pos) <= s.coverage)    
}

fn get_x_covered(y: i32, sensor: &Sensor) ->  Range<i32> {
    let dx = sensor.coverage - (sensor.pos.y-y).abs(); 
    //not quite sure why it's not +1 on the right, but it works out for solution 1 without double counting beacons, so fuck it
    (sensor.pos.x-dx)..(sensor.pos.x+dx) 
}

fn solve1(y:i32, sensors: &Vec<Sensor>) -> usize {
    let minx : i32 = sensors.iter().map(|s| s.pos.x - s.coverage).min().unwrap();
    let maxx : i32 = sensors.iter().map(|s| s.pos.x + s.coverage).max().unwrap();
    //println!("{}->{}",minx,maxx);
    let initial_range = minx..maxx+1; 
    count_occupied_at(y, &initial_range, sensors)
}

fn count_occupied_at(y:i32, space: &Range<i32>, sensors: &[Sensor]) -> usize {
    if space.len() <= 0 {
        return 0;
    }
    if let [s, rest@..] = &sensors[..] {
        let cover = get_x_covered(y, s);
        if cover.len() > 0 {
            let intersect = max(cover.start,space.start)..min(cover.end,space.end); 
            let left = space.start..min(cover.start,space.end);
            let right = max(cover.end,space.start)..space.end;
            //println!("{:?} ->{:?}->{:?} {:?} {:?}", space,cover, intersect, left, right);
            return intersect.len() + count_occupied_at(y, &left, rest) + count_occupied_at(y, &right, rest)
        } else {
            return count_occupied_at(y, space, rest)
        }
    } else {
       return 0
    }
}   



fn is_within_bounds(p: &Point, limit: i32) -> bool {
    return p.x >= 0 && p.x <= limit &&
           p.y >= 0 && p.y <= limit
}

fn solve2(limit: i32, sensors: &Vec<Sensor>) -> i64 {
    let mut lz : Vec<i32> = Vec::new();
    let mut lw : Vec<i32> = Vec::new();
    for s in sensors {
        lz.push(s.pos.x + s.pos.y + s.coverage+1);
        lz.push(s.pos.x + s.pos.y - s.coverage-1);
        lw.push(s.pos.x - s.pos.y + s.coverage+1);
        lw.push(s.pos.x - s.pos.y - s.coverage-1);
    }

    let mut points : HashSet<Point> = HashSet::new();
    //iterate over all intersections of z and w lines
    //the point must necessarily be in one of these locations
    //to create the point in x,y space we use the formula below
    //(how to derive it is left as an exercise to the future me)
    for z in &lz {
        for w in &lw {
            points.insert(Point {x:(z+w)/2, y:(z-w)/2});    
        }
    }
    
    let sol = points.iter()
        .filter(|p| !is_covered(&p, sensors))
        .filter(|p| is_within_bounds(&p, limit))
        .next()
        .unwrap();
    
    (sol.x as i64)*(limit as i64)+(sol.y as i64) 
    
}

fn main() {
    //let (fname,y,limit) = ("test",10,20);
    let (fname,y,limit) = ("input",2_000_000,4_000_000);
 
    let content = fs::read_to_string(fname).unwrap();
    let lines = split_lines(&content);
    let sensors:Vec<Sensor> = lines.into_iter().map(parse).collect();
    
    let ans1 = solve1(y,&sensors);
    let ans2 = solve2(limit,&sensors);
    println!("{},{}",ans1,ans2);
}
