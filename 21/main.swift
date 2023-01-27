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
let ans2 = 0

assert(ans1==194501589693264)

print("\(ans1),\(ans2)")
