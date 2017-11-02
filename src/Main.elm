module Main exposing (..)

import Data.Model exposing (Model, init)
import Html exposing (Html, program)
import Messages exposing (Msg)
import State exposing (updateWithCmds, subscriptions)
import Views.Main exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = updateWithCmds
        , subscriptions = subscriptions
        }
