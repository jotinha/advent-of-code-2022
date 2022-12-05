import System.IO
import Data.List
import Data.Maybe
import Text.Read

type Instruction = (Int, Int, Int)
type Stack = [Char]
data Version = A | B deriving (Eq)

maybeAt :: Int -> [a] -> Maybe a
maybeAt i xs | i < 0 = Nothing 
             | i >= length xs  = Nothing
             | otherwise = Just (xs !! i)

parseInt :: String -> Int
parseInt s = fromMaybe 0 (readMaybe s :: Maybe Int)

getAllNumbers :: String -> [Int]
getAllNumbers line = filter (>0) $ map parseInt $ words line 

parseInstruction :: String -> Instruction 
parseInstruction = toTuple . getAllNumbers
    where toTuple (x:y:z:rest) = (x,y,z)

isin xs x = any (== x) xs
iswhitespace = isin " \n\t\r"
trim = dropWhileEnd iswhitespace . dropWhile iswhitespace

header text = takeWhile (not.null.trim) text 
body text = dropWhile null $ dropWhile (not.null) $ map trim text

getColumn :: Int -> [[a]] -> [a]
getColumn i xs = catMaybes $ map (maybeAt i) xs

getStack :: Int -> [String] -> Stack
getStack i lines = trim $ getColumn ((i-1)*4+1) lines

parseStacks :: [String] -> [Stack]
parseStacks ls = map (\i -> getStack i rows) [1..maxIdx] 
    where 
        rows = init ls
        maxIdx = last $ getAllNumbers $ last ls 
        
parseInputData :: String -> ([Instruction],[Stack])
parseInputData contents = (map parseInstruction (body ls), parseStacks (header ls))
    where ls = lines contents

addToStack :: Stack -> Stack -> Stack
addToStack what dest = dest ++ what

execute :: Instruction -> [Stack] -> Version -> [Stack]
execute (n, from, to) stacks version = [newStackAt i | i <- [1..(length stacks)]]
    where 
        toMove = take n $ oldStackAt from
        toMove' | version == A = reverse toMove
                | version == B = toMove
        oldStackAt i = stacks !! (i-1)
        newStackAt i | i == from = drop n (oldStackAt i) 
                     | i == to = toMove' ++ (oldStackAt i)
                     | otherwise = oldStackAt i
    
executeMany :: [Instruction] -> [Stack] -> Version -> [Stack]
executeMany insts stacks version = foldl (\acc inst -> execute inst acc version) stacks insts

topOfStacks :: [Stack] -> [Char]
topOfStacks = map head

resultsPartA contents = topOfStacks $ executeMany instructions stacks A
    where (instructions, stacks) = parseInputData contents
resultsPartB contents = topOfStacks $ executeMany instructions stacks B
    where (instructions, stacks) = parseInputData contents

main = do
    contents <- readFile "input"
    putStrLn $ (resultsPartA contents) ++ "," ++ (resultsPartB contents)
    
