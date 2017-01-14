module Wizard.Types exposing (..)


type alias Model =
    { title : String
    , planningMethod : String
    }


type Msg
    = SetTitle String
    | SetPlanningMethod String
