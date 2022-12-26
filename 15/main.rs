use std::fs;

struct Point {x:i32,y:i32}
struct Pair {sensor: Point, beacon: Point}

fn parse(line: &str) -> Pair {

    let ns : Vec<i32> = line
        .split(['=',',',':'])
        .map(|x| x.parse::<i32>())
        .filter(|x| x.is_ok())
        .map(|x| x.unwrap()).
        collect();
    Pair {
        sensor: Point {x:ns[0], y:ns[1]},
        beacon: Point {x:ns[2], y:ns[3]}
    }
}

fn splitlines(content: &str) -> Vec<&str> {
    content 
        .split('\n')
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .collect()

}

fn main() {
    let content = fs::read_to_string("test").unwrap();
    let lines = splitlines(&content);
    let pairs:Vec<_> = lines.into_iter().map(parse).collect();

}
