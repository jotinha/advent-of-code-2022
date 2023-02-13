let explode s = List.init (String.length s) (String.get s);;
let implode cs = String.of_seq (List.to_seq cs);; 

print_endline (implode (explode "Hello world"));;

let add1 x y c = 
    let t = x+y+c in 
    if t >= 5 then (t-5,1) else (t,0)
;;

let rec addr xs ys carry = 
    match (xs,ys) with 
        | (x :: xs', y::ys') -> let (t,carry') = (add1 x y carry) in t :: addr xs' ys' carry' 
        | ([],[]) -> if carry == 1 then [1] else []
        | ([], _) -> addr [0] ys carry
        | (_, []) -> addr xs [0] carry
;;

let add xs ys = List.rev (addr (List.rev xs) (List.rev ys) 0);;

let print_list l = List.map (Printf.printf "%i,") l;;

print_list (add [3] [4; 3]) 
;;
