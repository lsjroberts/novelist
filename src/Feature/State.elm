module Feature.State exposing (init, update, subscriptions)

import Feature.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
