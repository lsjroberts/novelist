module Main exposing (..)

import Html exposing (program)
import Data.Model exposing (init)
import State exposing (updateWithStorage, subscriptions)
import Views.Main exposing (view)


-- PROGRAM


main =
    program
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }
