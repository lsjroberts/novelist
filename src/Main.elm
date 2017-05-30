module Main exposing (..)

import Html exposing (program)
import Novelist exposing (init, view, update, subscriptions)


-- PROGRAM


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
