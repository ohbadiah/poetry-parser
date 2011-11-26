module PoemAnalyzer(getWords, justWords, wordList) where

import CMUPronouncingDictionary
import Test.HUnit
import Data.Map (Map)
import qualified Data.Map as Map
import Data.List.Split(splitOn)
import Data.Maybe

-- | Given a String, splits string on spaces, removing empty strings
wordList :: String -> [String]
wordList text = filter (/= "") $ splitOn " " text

-- | Given a list of tokens, returns an analysis of the poem pieces
getWords :: [String] -> Dictionary -> [[Maybe Word]]
getWords strs dict = map (map (getWord dict)) broken where
  broken = splitOn ["\n"] strs

testGetWords :: Test
testGetWords = "Test getWords" ~: TestList [
  "fox" ~: getWords ["fox"] testDictionary ~?= [[justFox]],
  "fox with breaks" ~: getWords ["fox", "\n", "fox", "fox"] testDictionary ~?= 
    [[justFox], [justFox, justFox]]
  ] where
  justFox = Just testWordFox

testDictionary :: Dictionary
testDictionary = Map.fromList [
  ("fox", testWordFox), 
  ("pox", testWordPox)
  ]

-- | Removes all Nothing's from the list and collapses entries
justWords :: [[Maybe Word]] -> [[Word]]
justWords w = filter (not . null) (map onlyWords w) where
  onlyWords :: [Maybe Word] -> [Word]
  onlyWords maybeWords = map fromJust (filter isJust maybeWords)

testJustWords :: Test
testJustWords = "Test justWords" ~: TestList [
  justWords [[Just testWordFox, Nothing], [Nothing, Nothing]] ~?= 
    [[testWordFox]]
  ]

-- | Returns statistics about a word given the word
getWord :: Dictionary -> String -> Maybe Word
getWord dict str = Map.lookup str dict

testGetWord :: Test
testGetWord = "Test getWord" ~: TestList [
  "just" ~: getWord testDictionary "fox" ~?= Just testWordFox,
  "nothing" ~: getWord testDictionary "nothing" ~?= Nothing
  ]

testWords :: [Word]
testWords = [testWordFox, testWordPox]


test :: IO ()
test = do
  runTestTT (TestList [
    testGetWord,
    testJustWords,
    testGetWords
    ])
  return ()