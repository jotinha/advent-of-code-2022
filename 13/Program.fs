
type Packet = Num of int | List of list<Packet>

let lines = System.IO.File.ReadAllLines("test") |> Array.toList
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

let skipEveryNth n xs = [for (i,x) in (List.indexed xs) do if i%n<(n-1) then yield x]

let packets = List.map (toChars >> parse) (skipEveryNth 3 lines) 

let rec pairs = function | x1::x2::xs -> (x1,x2) :: pairs xs | [] -> []

let inner str = str |> List.tail |> List.rev |> List.tail |> List.rev 

let printChars s = List.append s ['\n'] |> List.map (fun a -> printf "%c" a)
let rec printPacket = function 
    | Num x -> printf "%d " x 
    | List xs -> printf("["); List.map printPacket xs; printf("\b] ")

let x = "[10,20,[3,4],[[5,6],7],1]" 
//printPacket (parse (toChars x))
packets |> List.last |> printPacket 
