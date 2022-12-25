import Data.Maybe
import Text.Read
import Text.Printf
import Data.List
import Data.Char

data Packet = Num Int | List [Packet] deriving (Show, Eq)

parseInt :: String -> Maybe Int
parseInt s = readMaybe s
justParseInt = fromJust.parseInt

enumerate = zip [0..]

parsetext :: String -> [Packet]
parsetext contents = map (parse.snd) $ filter noteverythird $ (enumerate.lines) contents 
    where noteverythird (i,_) = i `mod` 3 /= 2

pairs :: [Packet] -> [(Packet,Packet)]
pairs (left:right:rest) = (left,right):(pairs rest)
pairs [] = []

inner = init.tail

parse :: String -> Packet
parse s = x where (_,x) = parseNext s

parseNext :: String -> (String, Packet)
parseNext "" = ("", List []) 
parseNext ('[':s) = (rest, List x) where (rest,x) = parseList s
parseNext (',':s) = parseNext s --skip
parseNext s = parseNumber s

parseNumber s = (rest, x')
    where x = takeWhile isDigit s
          x' = Num $ justParseInt x
          rest = drop (length x) s

parseList :: String -> (String,[Packet])
parseList (']':rest) = (rest, [])
parseList s = (rest', x:xs)
    where (rest, x) = parseNext s
          (rest',xs) = parseList rest

tolist :: Packet -> Packet
tolist (Num x) = List [Num x]
tolist l = l

cmp' :: Packet -> Packet -> Int
cmp' (Num l) (Num r) | l < r = -1 | l > r = 1 | otherwise = 0
cmp' (List ls) (List rs) = case (ls,rs) of 
                    ([],[]) -> 0
                    ([],_) -> -1 
                    (_,[]) -> 1
                    (l:ls, r:rs) -> if c /= 0 then c else cmp' (List ls) (List rs)
                        where c = cmp' l r
cmp' l r = cmp' (tolist l) (tolist r) 

solve1 :: [Packet] -> Int
solve1 packets = sum [i+1 | (i,(a,b)) <- (enumerate (pairs packets)), correctorder a b]

correctorder p1 p2 = cmp' p1 p2 == -1
incorrectorder p1 p2 = cmp' p1 p2 == 1

sortpackets :: [Packet] -> [Packet]
sortpackets (p:ps) = lt++[p]++gt
    where lt = sortpackets $ filter (incorrectorder p) ps
          gt = sortpackets $ filter (correctorder p) ps
sortpackets [] = []

dividers = map parse ["[[2]]","[[6]]"] 
isdivider p = p `elem` dividers

solve2 :: [Packet] -> Int 
solve2 packets = (i1+1)*(i2+1)
    where
        packets' = sortpackets $ packets ++ dividers
        ((i1,_):(i2,_):_) = filter (isdivider.snd) $ enumerate packets' 

main = do
    contents <- readFile "input"
    let packets = parsetext contents
    let ans1 = solve1 packets 
    let ans2 = solve2 packets 
    putStrLn $ (show ans1)++","++(show ans2) 
