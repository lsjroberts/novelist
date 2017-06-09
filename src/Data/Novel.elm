module Data.Novel exposing (Novel)

import Data.Scene exposing (Scene)
import Date exposing (Date)


type alias Novel r =
    { r
        | scenes : List Scene
        , title : String
        , author : String
        , targetWordCount : Maybe Int
        , deadline : Maybe Date
    }
