use std::fs;

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


fn splitlines(content: &str) -> Vec<&str> {
    content 
        .split('\n')
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .collect()

}

fn dist(a: &Point, b: &Point) -> i32 { (a.x-b.x).abs() + (a.y-b.y).abs() }

fn iscoveredby(p: &Point, s: &Sensor) -> bool { 
    dist(p,&s.pos) <= s.coverage
}
fn iscoveredbyany(p: &Point, sensors: &Vec<Sensor>) -> bool {
    sensors.iter().any(|s| iscoveredby(p,s))    
}
fn beaconat(p: &Point, sensors: &Vec<Sensor>) -> bool {
    sensors.iter().any(|s| s.beacon.x == p.x && s.beacon.y == p.y)
}

fn getxrange(y: i32, sensors: &Vec<Sensor>) -> Vec<Point> { 
    let xmin = sensors.iter().map(|s| s.pos.x - s.coverage).min().unwrap();
    let xmax = sensors.iter().map(|s| s.pos.x + s.coverage).max().unwrap();
    (xmin-1..xmax+1).map(|x| Point {x:x,y:y}).collect()

}

fn main() {
    let content = fs::read_to_string("input").unwrap();
    let lines = splitlines(&content);
    let sensors:Vec<Sensor> = lines.into_iter().map(parse).collect();
    
    let y = 2000000;
    let ans1 = getxrange(y,&sensors)
        .iter()
        .filter(|p| iscoveredbyany(p,&sensors))
        .filter(|p| !beaconat(p,&sensors))
        .count();
    println!("{},{}",ans1,"TODO");
}
