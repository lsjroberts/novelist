port module Editor.State exposing (init, update, subscriptions)

import Json.Encode
import Json.Decode
import Debug
import Editor.Types exposing (..)
import Editor.Decode
import Workspace.Types


init : ( Model, Cmd Msg )
init =
    ( Editor.Types.empty
    , Cmd.none
    )


port showOpenDialog : () -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowOpenDialog ->
            ( model, showOpenDialog () )

        OpenProject metaData ->
            ( Editor.Decode.decodeMetaData metaData, Cmd.none )

        WorkspaceMsg (Workspace.Types.SceneMsg msg) ->
            ( model, Cmd.none )


port openProject : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    openProject OpenProject
