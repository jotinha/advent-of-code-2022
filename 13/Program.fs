
type Packet = Num of int | List of list<Packet>

let lines = System.IO.File.ReadAllLines("input") |> Array.toList
let toString cs = System.String.Concat(Array.ofList(cs: list<char>))
let toChars = Seq.toList

let parseNumber s = 
    let x = List.takeWhile System.Char.IsDigit s
    let x' = x |> toString |> int |> Num
    let rest = List.skip (List.length x) s
    (rest, x')

let rec parseList = function
    | ']'::s -> (s, List [])
    | s -> let rest, x = parseNext s
           let rest', List xs = parseList rest 
           (rest',List (x::xs))

and parseNext = function
    | [] -> ([],List []) 
    | '['::s -> parseList s 
    | ','::s -> parseNext s 
    | s -> parseNumber s

let parse line = snd (parseNext line)

let rec order = function
    | (Num l, Num r) -> if l < r then -1 else if l > r then 1 else 0
    | (Num l, List r) -> order (List [Num l], List r)
    | (List l, Num r) -> order (List l, List [Num r])
    | (List l, List r) -> match (l,r) with 
        | ([],[]) -> 0
        | ([],_) -> -1
        | (_,[]) -> 1
        | (l::ls, r::rs) -> let c = order (l, r)
                            if c = 0 then order (List ls,List rs) else c

let correctorder pair = (order pair) = -1
let incorrectorder pair = (order pair) = 1

let solve1 packets = 
    let rec pairs = function | x1::x2::xs -> (x1,x2) :: pairs xs | [] -> []
    let packetpairs = pairs packets
    List.sum [for (i,x) in (List.indexed packetpairs) do 
        if correctorder x then 
            yield i+1]
        
let inner str = str |> List.tail |> List.rev |> List.tail |> List.rev 
let skipEveryNth n xs = [for (i,x) in (List.indexed xs) do if i%n<(n-1) then yield x]
let packets = List.map (toChars >> parse) (skipEveryNth 3 lines) 


let printChars s = List.append s ['\n'] |> List.map (fun a -> printf "%c" a)
let rec printPacket = function 
    | Num x -> printf "%d " x 
    | List xs -> printf("["); List.map printPacket xs; printf("\b] ")

//packets |> List.last |> printPacket 
let ans1 = solve1 packets
let ans2 = 0
printf "%d,%d" ans1 ans2
