module Wizard.State exposing (init, update, subscriptions)

import Wizard.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { title = "Pride and Prejudice"
      , planningMethod = "Story Grid"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetTitle title ->
            ( { model | title = title }, Cmd.none )

        SetPlanningMethod method ->
            ( { model | planningMethod = method }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
