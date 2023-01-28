import Foundation

var d : [String: Cmd]  = [:]

enum Cmd {
    case n(Double)
    case op(String, String, String)
}

func parse(command: String) -> Cmd {
    let tokens = command 
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: .whitespaces)
    switch tokens.count {
        case 1: return .n(Double(tokens[0])!)
        case 3: return .op(tokens[1], tokens[0], tokens[2]) 
        default: fatalError("invalid command string: \(command)")
    }
}

func parse(file: String)  {
    let lines = try! String(contentsOfFile: file, encoding: .utf8)
                    .components(separatedBy: .newlines) 
    for line in lines {
        if !line.isEmpty {
            let word_cmd = line.components(separatedBy: ":")
            d[word_cmd[0]] = parse(command: word_cmd[1])
        }
    }
}

func execute(_ word: String) -> Double {
    switch d[word] {
        case let .n(n) : return n
        case let .op("+", w1, w2): return execute(w1) + execute(w2)
        case let .op("-", w1, w2): return execute(w1) - execute(w2)
        case let .op("/", w1, w2): return execute(w1) / execute(w2)
        case let .op("*", w1, w2): return execute(w1) * execute(w2)
        default: fatalError("unexpected cmd")
    }    
}

parse(file: "input")
let ans1 = Int(execute("root"))
assert(ans1==194501589693264)

// For part II, we need to replace the root operation with a diff
// and use a root finding algorithm 

if case let .op(_,w1,w2) = d["root"] {
    d["root"] = .op("-",w1,w2)
}
func shout(n: Double) -> Double {
    d["humn"] = .n(n)
    return execute("root")
}

func root(f: (Double)->(Double), x0: Double, x1: Double, y0: Double? = nil, y1: Double? = nil) -> Double {
    // https://en.wikipedia.org/wiki/Secant_method
    let y0 = y0 ?? f(x0)
    let y1 = y1 ?? f(x1)
    let x = x1 - y1*(x1-x0)/(y1-y0)
    let y = f(x)
    if y == 0 {
        return x 
    } else {
        return root(f:f, x0:x1, x1:x, y0: y1, y1:y)
    } 
}

let ans2 = Int(root(f:shout, x0:0, x1:100000))

print("\(ans1),\(ans2)")
