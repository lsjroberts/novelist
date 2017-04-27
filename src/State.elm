module State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Debug
import Response exposing (..)
import Set
import Types exposing (..)
import Editor.State
import Editor.Types


init : ( Model, Cmd Msg )
init =
    let
        ( editor, _ ) =
            Editor.State.init
    in
        ( { route = EditorRoute
          , editor = editor
          }
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        SetRoute route ->
            ( { model | route = route }
            , Cmd.none
            )

        EditorMsg editorMsg ->
            case editorMsg of
                Editor.Types.OpenProject metaData ->
                    update (SetRoute EditorRoute)
                        (let
                            ( editor, _ ) =
                                Editor.State.update editorMsg model.editor
                         in
                            { model | editor = editor }
                        )

                _ ->
                    Editor.State.update editorMsg model.editor
                        |> mapModel (\x -> { model | editor = x })
                        |> mapCmd EditorMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map EditorMsg (Editor.State.subscriptions model.editor)
        ]
