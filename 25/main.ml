let explode s = List.init (String.length s) (String.get s);;
let implode cs = String.of_seq (List.to_seq cs);; 

let read_lines fn =
    let rec read_lines' ic =
        match input_line ic with
            | line -> line :: read_lines' ic
            | exception End_of_file -> close_in ic; []
    in read_lines' (open_in fn);;

let dec = function | '0' -> 0 | '1' -> 1 | '2' -> 2 | '-' -> -1 | '=' -> -2 | _ -> -666
let enc = function | 0 -> '0' | 1 -> '1' | 2 -> '2' | -1 -> '-' | -2 -> '=' | _ -> '?'

let add_single x y c = 
    let t = (dec x) + (dec y) + c in 
    if t >= 3  then (enc (t-5), 1) else 
    if t <= -3 then (enc (t+5),-1) else 
    (enc t, 0);;

let rec addr xs ys carry = 
    match (xs,ys) with 
        | (x :: xs', y::ys') -> let (t, carry') = (add_single x y carry) in t :: addr xs' ys' carry' 
        | ([],[]) -> if carry == 1 then ['1'] else []
        | ([], _) -> addr ['0'] ys carry
        | (_, []) -> addr xs ['0'] carry
;;

let add a b = 
    let xs = a |> explode |> List.rev
    and ys = b |> explode |> List.rev
    in addr xs ys 0 |> List.rev |> implode
;;

let ans1 = read_lines "input" |> List.fold_left add "";;

Printf.printf "%s,*\n" ans1;; 
