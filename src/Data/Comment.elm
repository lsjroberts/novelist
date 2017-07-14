module Data.Comment exposing (Comment)

import Date exposing (Date)


type alias Comment =
    { message : String
    , author : String
    , timestamp : Int
    }
