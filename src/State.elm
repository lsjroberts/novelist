module State exposing (..)

import Data.File exposing (..)
import Data.Model exposing (..)
import Dict exposing (Dict)
import Messages exposing (..)
import Set exposing (Set)


updateWithCmds : Msg -> Model -> ( Model, Cmd Msg )
updateWithCmds msg model =
    ( update msg model, Cmd.none )


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

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
                , openFiles = Set.remove fileId model.openFiles
            }

        OpenFile fileId ->
            { model
                | activeFile = Just fileId
                , openFiles = Set.insert fileId model.openFiles
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
