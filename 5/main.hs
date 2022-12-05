import System.IO
import Data.List
import Data.Maybe
import Text.Read

getStack :: Int -> String -> [Char]
getStack 1 _ = ['N','Z'] 
getStack 2 _ = ['D','C','M']
getStack 3 _ = ['P']

parseInt :: String -> Int
parseInt s = fromMaybe 0 (readMaybe s :: Maybe Int)

getAllNumbers :: String -> [Int]
getAllNumbers line = filter (>0) $ map parseInt $ words line 

parseInstruction :: String -> (Int,Int,Int)
parseInstruction = toTuple . getAllNumbers
    where toTuple (x:y:z:rest) = (x,y,z)

isin x xs = any (== x) xs
iswhitespace x = x `isin` " \n\t\r"
trim = dropWhileEnd iswhitespace . dropWhile iswhitespace
header text = takeWhile (not.null.trim) text 
body text = dropWhile null $ dropWhile (not.null) $ map trim text

main = do
    putStrLn "Hello world"
    contents <- readFile "test"
    putStrLn (show $ map parseInstruction $ body $ lines contents)    
    
--mapM_ putStrLn (body $ lines contents)
