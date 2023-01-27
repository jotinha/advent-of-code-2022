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
    if tokens.count == 1 {
        return .n(Double(tokens[0])!)
    } else {
        return .op(tokens[1], tokens[0], tokens[2]) 
    }
}

func parse(file: String)  {
    let lines = try! String(contentsOfFile: file, encoding: .utf8)
                    .components(separatedBy: .newlines) 
    for line in lines {
        let word_cmd = line.components(separatedBy: ":")
        d[word_cmd[0]] = parse(command: word_cmd[1])
    }
}

parse(file: "test")
print(d)
