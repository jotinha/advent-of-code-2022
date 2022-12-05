import System.IO
import Data.List
import Data.Maybe
import Text.Read

data Instruction = Instruction {
    stack :: Int, 
    from :: Int,
    to :: Int
} deriving Show

type Stack = [Char]

maybeAt :: Int -> [a] -> Maybe a
maybeAt i xs | i < 0 = Nothing 
             | i >= length xs  = Nothing
             | otherwise = Just (xs !! i)

parseInt :: String -> Int
parseInt s = fromMaybe 0 (readMaybe s :: Maybe Int)

getAllNumbers :: String -> [Int]
getAllNumbers line = filter (>0) $ map parseInt $ words line 

parseInstruction :: String -> Instruction 
parseInstruction = fromList . getAllNumbers
    where fromList (x:y:z:rest) = Instruction x y z

isin xs x = any (== x) xs
iswhitespace = isin " \n\t\r"
trim = dropWhileEnd iswhitespace . dropWhile iswhitespace

header text = takeWhile (not.null) $ map trim text 
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

main = do
    putStrLn "Hello world"
    contents <- readFile "test"
    putStrLn (show $ parseInputData contents) 
    
