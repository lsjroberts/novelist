module Data.Scene exposing (..)

import Data.Token exposing (Token, tokensToPlainText)
import Utils.String exposing (getStringWordCount)


type alias Scene =
    { id : Int
    , parent : Maybe Int
    , name : String
    , content : List Token
    , history : List (List Token)
    , commit : Int
    , wordTarget : Int
    }


getSceneWordCount : Scene -> Int
getSceneWordCount =
    .content >> tokensToPlainText >> getStringWordCount
