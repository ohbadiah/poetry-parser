module PoemClassifier (
  classify, 
  PoemClassifier.test) where

import CMUPronouncingDictionary
import PoemAnalyzer
import PoemParser
import Test.HUnit
import Data.Maybe (catMaybes)

-- | Use to classify a poem. Given a poem, and dictionary, 
-- this will output information about its type, rhyming scheme, and meter.
classify :: String -> String -> String
classify poem dictText = poemDescription where
  dict = loadWords dictText $ words poem
  res = justWords $ getWords (lines poem) dict
  poemDescription = analyze res

testClassify :: Test 
testClassify = "Test classify" ~: TestList [
  -- fails right now
  classify "something something fox\nsomething something pox" 
    "SOMETHING  S AH1 M TH IH0 NG\nFOX  F AA1 K S\nPOX  P AA1 K S" ~?= 
    "Rhyming poem aa"
  ]

-- | Returns a description of the poem
analyze :: [PoemLine] -> String
analyze poem = if null result then "unsupported form" else result where 
  result = unwords $ catMaybes $ map tryParser supportedParsers 
  tryParser = description toks 
  toks = PoemParser.lex poem 

testAnalyze :: Test
testAnalyze = "Test analyze" ~: TestList [
  analyze [[testWordFox],[testWordPox]] ~?= "Rhyming poem: aa"
  ]

description :: [Token] -> (PoemParser RhymeMap, String) -> Maybe String
description toks (pp, str) = case doParse pp toks of
  [(_,[])] -> Just str --only succeed if the parser consumes the whoel poem
  _ -> Nothing 

supportedParsers :: [(PoemParser RhymeMap, String)]
supportedParsers = [(haiku, "Haiku"), 
                    (aba, "Rhyming poem: aba"),
                    (aabba, "Rhyming poem: aabba"),
                    (limerick, "Limerick"),
                    (iambicPentameter, "Iambic Pentameter"),
                    (sonnetRhyme, "ababcdcdefefgg rhyme scheme"),
                    (shakespeareanSonnet, "Shakespearean Sonnet (!!)") ]

test :: IO ()
test = do
  runTestTT (TestList [
    testAnalyze,
    testClassify
    ])
  return ()
