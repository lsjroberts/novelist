module Main exposing (..)

import Data.Model exposing (Model, init)
import Html exposing (Html, programWithFlags)
import Messages exposing (Msg)
import State exposing (update, subscriptions)
import Views.Main exposing (view)


main : Program Int Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
