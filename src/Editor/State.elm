port module Editor.State exposing (init, update, subscriptions)

import Json.Encode
import Json.Decode
import Debug
import Editor.Types exposing (..)
import Editor.Decode
import Binder.Types
import Workspace.Types


init : ( Model, Cmd Msg )
init =
    ( Editor.Types.empty
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowOpenDialog ->
            ( model, showOpenDialog () )

        OpenProject metaData ->
            ( Editor.Decode.decodeMetaData metaData, Cmd.none )

        AddFile parentId ->
            ( { model
                | files =
                    (model.files
                        ++ [ File (model.lastFileId + 1) Scene parentId "New File" ]
                    )
                , lastFileId = model.lastFileId + 1
              }
            , Cmd.none
            )

        OpenFile id ->
            ( { model | active = Just id }, Cmd.none )

        WorkspaceMsg (Workspace.Types.SceneMsg sceneMsg) ->
            ( model, Cmd.none )

        BinderMsg binderMsg ->
            case binderMsg of
                Binder.Types.AddFile parentId ->
                    update (AddFile parentId) model

                Binder.Types.OpenFile fileName ->
                    update (OpenFile fileName) model

                Binder.Types.NoOp ->
                    ( model, Cmd.none )


port showOpenDialog : () -> Cmd msg


port openProject : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    openProject OpenProject
