module Data.Scene exposing (Scene)

import Data.Token exposing (Token)


type alias Scene =
    { id : Int
    , parent : Maybe Int
    , name : String
    , content : List Token
    , history : List (List Token)
    , commit : Int
    , wordTarget : Int
    }
