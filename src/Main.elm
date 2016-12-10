module Main exposing (..)

import Html exposing (program)
import State
import View


main =
    program
        { init = State.init
        , view = View.root
        , update = State.update
        , subscriptions = State.subscriptions
        }
