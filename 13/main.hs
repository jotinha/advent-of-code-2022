import Data.Maybe
import Text.Read
import Text.Printf

parseInt :: String -> Maybe Int
parseInt s = readMaybe s
justParseInt = fromJust.parseInt

pairs :: [String] -> [(String,String)]
pairs (left:right:_:rest) = (left,right):(pairs rest)
pairs (left:right:[]) = [(left,right)]

inner = init.tail

findclosing s = take i s
    where
        findi 0 idx (']':xs) = idx+1
        findi l idx (']':xs) = findi (l-1) (idx+1) xs
        findi l idx ('[':xs) = findi (l+1) (idx+1) xs
        findi l idx (_:xs) = findi l (idx+1) xs
        findi 0 idx [] = idx
        i = findi 0 0 s

findcomma s = takeWhile (/=',') s

nextelem :: String -> String        
nextelem ('[':xs) = '[':findclosing xs
nextelem xs = findcomma xs

elems' :: [String] -> String -> [String]
elems' acc "" = acc
elems' acc s = elems' (x:acc) $ drop (length x+1) s
    where x = nextelem s
elems s = reverse $ elems' [] s

islist = (== '[') . head 

cmps :: String -> String -> Int
cmps left right | islist left && islist right = cmpl (l left) (l right)
                | islist left && not (islist right) = cmpl (l left) [right]
                | not (islist left) && islist right = cmpl [left] (l right)
                | otherwise = cmpi (justParseInt left) (justParseInt right) 
   where l = elems.inner 
cmpi :: Int -> Int -> Int
cmpi left right | left < right = -1 | left > right = 1 | otherwise = 0

cmpl [] (y:ys) = -1
cmpl (x:xs) [] = 1
cmpl [] [] = 0
cmpl (x:xs) (y:ys)  | c == 0 = cmpl xs ys
                    | otherwise = c
    where c = cmps x y

solve1 pairs = sum [i | (i,r) <- (zip [1..] res), r == -1]
    where res = map (\(a, b) -> cmps a b ) pairs 

correctorder p1 p2 = cmps p1 p2 == -1
incorrectorder p1 p2 = cmps p1 p2 == 1

sortpackets :: [String] -> [String]
sortpackets (p:ps) = lt++[p]++gt
    where lt = sortpackets $ filter (incorrectorder p) ps
          gt = sortpackets $ filter (correctorder p) ps
sortpackets [] = []

flatten :: [(String,String)] -> [String]
flatten ((a,b):xs) = a:b:(flatten xs)
flatten [] = []

solve2 :: [(String,String)] -> Int 
solve2 pairs = i1*i2
    where
        dividers = ["[[2]]","[[6]]"] 
        packets = sortpackets $ (flatten pairs) ++ dividers 
        ((i1,_):(i2,_):_) = filter (\(i, s) -> s `elem` dividers) $ zip [1..] packets 

main = do
    contents <- readFile "input"
    let ans1 = solve1 $ pairs $ lines contents 
    let ans2 = solve2 $ pairs $ lines contents
    putStrLn $ (show ans1)++","++(show ans2) 
