module Wizard.Types exposing (..)

import Dict exposing (Dict)


type alias Model =
    { fields : Dict String String
    }


type Msg
    = SetField String String
