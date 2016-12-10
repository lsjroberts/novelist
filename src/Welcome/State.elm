module Welcome.State exposing (init, update, subscriptions)

import Animation
import Welcome.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( Model [] (Animation.style []), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
