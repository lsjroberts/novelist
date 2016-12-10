module State exposing (init, update, subscriptions)

import Platform.Cmd
import Response exposing (..)
import Types exposing (..)
import Scene.State
import Scene.Types
import Welcome.State
import Welcome.Types


init : ( Model, Cmd Msg )
init =
    let
        ( scene, _ ) =
            Scene.State.init

        ( welcome, _ ) =
            Welcome.State.init
    in
        ( Model scene welcome, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
