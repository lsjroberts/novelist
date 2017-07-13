port module State exposing (..)

import Date
import Json.Encode as Encode
import Time exposing (Time)
import Data.Decode exposing (decodeProject)
import Data.Encode exposing (modelEncoder)
import Data.Model exposing (Model)
import Data.Novel exposing (Novel)
import Data.Token exposing (markdownToTokens)
import Data.Ui exposing (ViewType(..), Selection)
import Messages exposing (Msg(..))


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        newModel =
            update msg model
    in
        ( newModel
        , setStorage (modelEncoder newModel)
        )


update : Msg -> Model -> Model
update msg model =
    case (Debug.log "msg" msg) of
        -- MAYBE DONT DO THIS
        GoToSettings _ ->
            model |> update (SetActiveView SettingsView)

        NewTime time ->
            { model | time = time }

        OpenProject project ->
            decodeProject project

        Select selection ->
            { model | selection = Just selection }

        SetActiveFile id ->
            { model | activeFile = Just id }

        SetActiveView activeView ->
            { model | activeView = activeView }

        SetSceneName id name ->
            model
                |> Data.Novel.updateScene id (\scene -> { scene | name = name })
                |> Data.Ui.updateFile id (\file -> { file | name = name })

        SetSceneWordTarget id targetString ->
            let
                wordTarget =
                    Result.withDefault 0 (String.toInt targetString)
            in
                model
                    |> Data.Novel.updateScene id (\scene -> { scene | wordTarget = wordTarget })

        SetAuthor author ->
            { model | author = author }

        SetDeadline deadlineString ->
            let
                deadlineResult =
                    Date.fromString (deadlineString ++ " 00:00:00")
            in
                case deadlineResult of
                    Ok deadline ->
                        { model | deadline = Just deadline }

                    Err err ->
                        Debug.log err model

        SetTitle title ->
            { model | title = title }

        SetTargetWordCount targetString ->
            { model
                | totalWordTarget =
                    targetString
                        |> String.toInt
                        |> Result.withDefault 0
                        |> Just
            }

        ToggleFileExpanded id ->
            model
                |> Data.Ui.updateFile id
                    (\file ->
                        { file
                            | expanded = not file.expanded
                        }
                    )

        Write id content ->
            let
                tokens =
                    markdownToTokens content
            in
                model
                    |> Data.Novel.updateScene id
                        (\scene ->
                            if tokens == scene.content then
                                scene
                            else
                                { scene
                                    | content = tokens
                                    , history = scene.content :: scene.history
                                    , commit = scene.commit + 1
                                }
                        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openProject OpenProject
        , gotoSettings GoToSettings
        , select Select
        , Time.every Time.minute NewTime
        ]



-- PORTS


port openProject : (String -> msg) -> Sub msg


port gotoSettings : (String -> msg) -> Sub msg


port setStorage : Encode.Value -> Cmd msg


port select : (Selection -> msg) -> Sub msg
