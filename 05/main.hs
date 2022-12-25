import System.IO
import Data.List
import Data.Maybe
import Text.Read

type Instruction = (Int, Int, Int)
type Stack = [Char]
data Version = A | B deriving (Eq)

parseInt :: String -> Maybe Int
parseInt s = readMaybe s

parseAllNumbers :: String -> [Int]
parseAllNumbers line = catMaybes $ map parseInt $ words line 

iswhitespace c = elem c " \n\t\r"
trim = dropWhileEnd iswhitespace . dropWhile iswhitespace

parseHeader = takeWhile (not.null.trim)
parseBody = dropWhile (null.trim) . dropWhile (not.null.trim)

getColumn :: Int -> [[a]] -> [a]
getColumn 0 = map head 
getColumn i = getColumn (i-1) . map tail

parseInstruction :: String -> Instruction 
parseInstruction line = (x,y,z) where [x,y,z] = parseAllNumbers line 

parseInstructions :: [String] -> [Instruction]
parseInstructions = map parseInstruction

parseStack :: Int -> [String] -> Stack
parseStack i lines = trim $ getColumn ((i-1)*4+1) lines

parseStacks :: [String] -> [Stack]
parseStacks ls = [parseStack i rows | i <- [1..maxIdx]]
    where 
        rows = init ls
        maxIdx = last $ parseAllNumbers $ last ls 

execute :: Version -> Instruction -> [Stack] -> [Stack]
execute version (n, from, to) stacks = [transform i s | (i,s) <- zip [1..] stacks]
    where 
        source = stacks !! (from-1)
        transform i s | i == from = drop n s
                      | i == to   = (pickup version n source) ++ s
                      | otherwise = s
        
pickup :: Version -> Int -> Stack -> Stack
pickup A n s = reverse $ take n s
pickup B n s = take n s

executeMany :: Version -> [Instruction] -> [Stack] ->  [Stack]
executeMany version insts stacks = foldl executor stacks insts
    where executor = flip (execute version)

topOfStacks :: [Stack] -> [Char]
topOfStacks = getColumn 0 

compute :: Version -> String -> [Char] 
compute version contents = topOfStacks $ executeMany version instructions stacks
    where 
        ls = lines contents
        instructions = parseInstructions $ parseBody ls
        stacks = parseStacks $ parseHeader ls

main = do
    contents <- readFile "input"
    putStr $ compute A contents
    putStr ","
    putStr $ compute B contents
    putStr "\n"
    
