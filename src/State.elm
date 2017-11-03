module State exposing (..)

import Data.File exposing (..)
import Data.Model exposing (..)
import Dict exposing (Dict)
import Messages exposing (..)
import Random.Pcg
import Set exposing (Set)
import Uuid


updateWithCmds : Msg -> Model -> ( Model, Cmd Msg )
updateWithCmds msg model =
    ( update msg model, Cmd.none )


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        AddScene ->
            let
                newScene =
                    File "New Scene" <|
                        SceneFile <|
                            Scene "" Draft [] 999 (Dict.fromList []) [] Nothing
            in
                { model
                    | files = Dict.insert (Uuid.toString model.currentUuid) newScene model.files
                    , activeFile = Just (Uuid.toString model.currentUuid)
                }
                    |> update NewUuid

        CloseFile fileId ->
            { model
                | activeFile =
                    case model.activeFile of
                        Just activeFile ->
                            if activeFile == fileId then
                                Nothing
                            else
                                model.activeFile

                        Nothing ->
                            Nothing
                , openFiles = List.filter (\f -> not <| f == fileId) model.openFiles
            }

        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    Random.Pcg.step Uuid.uuidGenerator model.currentSeed
            in
                { model
                    | currentUuid = newUuid
                    , currentSeed = newSeed
                }

        OpenFile fileId ->
            { model
                | activeFile = Just fileId
                , openFiles =
                    if not <| List.member fileId model.openFiles then
                        fileId :: model.openFiles
                    else
                        model.openFiles
            }

        SetActivity activity ->
            { model | activity = activity }

        SetWordTarget targetString ->
            let
                wordTarget =
                    targetString
                        |> String.toInt
                        |> Result.toMaybe

                updateFile maybeFile =
                    case maybeFile of
                        Just file ->
                            case file.fileType of
                                SceneFile scene ->
                                    Just
                                        { file
                                            | fileType =
                                                SceneFile
                                                    { scene
                                                        | wordTarget = wordTarget
                                                    }
                                        }

                                _ ->
                                    Just file

                        Nothing ->
                            Nothing
            in
                case model.activeFile of
                    Just activeFile ->
                        { model
                            | files = Dict.update activeFile updateFile model.files
                        }

                    Nothing ->
                        model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
