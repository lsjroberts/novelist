module State exposing (..)

import Data.File exposing (..)
import Data.Model exposing (..)
import Data.Palette exposing (..)
import Dict exposing (Dict)
import Dom
import Keyboard.Combo
import Messages exposing (..)
import Random.Pcg
import Task
import Uuid


updateWithCmds : Msg -> Model -> ( Model, Cmd Msg )
updateWithCmds msg model =
    case msg of
        Ui (Combos comboMsg) ->
            let
                ( updatedCombos, comboCmd ) =
                    Keyboard.Combo.update comboMsg model.keyCombos
            in
                ( { model | keyCombos = updatedCombos }, comboCmd )

        _ ->
            let
                cmd =
                    case msg of
                        Ui (SetPalette (Files _)) ->
                            Task.attempt (Ui << FocusPaletteInput) (Dom.focus "palette-input")

                        _ ->
                            Cmd.none
            in
                ( update msg model, cmd )


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        Data dataMsg ->
            updateData dataMsg model

        Ui uiMsg ->
            updateUi uiMsg model

        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    Random.Pcg.step Uuid.uuidGenerator model.currentSeed
            in
                { model
                    | currentUuid = newUuid
                    , currentSeed = newSeed
                }


updateData : DataMsg -> Model -> Model
updateData msg model =
    case msg of
        AddCharacter ->
            let
                newCharacter =
                    File "New Character" <|
                        CharacterFile <|
                            Character []
            in
                { model
                    | files = Dict.insert (Uuid.toString model.currentUuid) newCharacter model.files
                    , activeFile = Just (Uuid.toString model.currentUuid)
                }
                    |> update NewUuid

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

        RenameFile fileId newName ->
            { model
                | files =
                    Dict.update fileId
                        (\mf ->
                            case mf of
                                Just f ->
                                    Just { f | name = newName }

                                Nothing ->
                                    Nothing
                        )
                        model.files
            }

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


updateUi : UiMsg -> Model -> Model
updateUi msg model =
    case msg of
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
                |> update (Ui ClosePalette)

        ClosePalette ->
            { model | palette = Closed }

        Combos msg ->
            model

        FocusPaletteInput msg ->
            model

        OpenFile fileId ->
            { model
                | activeFile = Just fileId
                , openFiles =
                    if not <| List.member fileId model.openFiles then
                        fileId :: model.openFiles
                    else
                        model.openFiles
            }
                |> update (Ui ClosePalette)

        SearchName search ->
            { model | palette = Files search }

        SetPalette palette ->
            { model | palette = palette }

        SetActivity activity ->
            { model | activity = activity } |> update (Ui ClosePalette)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.Combo.subscriptions model.keyCombos
