module Main exposing (..)

import Data.Model exposing (Model, init)
import Html exposing (Html, program)
import Messages exposing (Msg)
import State exposing (update, subscriptions)
import Views.Main exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init 0
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
