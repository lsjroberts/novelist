module Main exposing (..)

import Html exposing (program)
import Novelist exposing (init, view, updateWithStorage, subscriptions)


-- PROGRAM


main =
    program
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }
