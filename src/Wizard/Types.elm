module Wizard.Types exposing (..)

import Dict exposing (Dict)
import Interactable.Types


type alias Model =
    { fields : Dict String String
    , startButton : Interactable.Types.Model
    }


type Msg
    = SetField String String
    | StartButtonInteraction Interactable.Types.Msg
    | StartStory
