module Wizard.State exposing (init, update, subscriptions)

import Dict
import Wizard.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { fields =
            Dict.fromList
                [ ( "title", "Pride And Prejudice" )
                , ( "planningMethod", "Story Grid" )
                ]
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetField field value ->
            ( { model | fields = Dict.insert field value model.fields }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
