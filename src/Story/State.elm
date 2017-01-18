module Story.State exposing (init, update, subscriptions)

import Response exposing (..)
import Story.Types exposing (..)
import Scene.State


init : ( Model, Cmd Msg )
init =
    let
        ( scene, _ ) =
            Scene.State.init
    in
        ( Model scene [ scene ], Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
