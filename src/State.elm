port module State exposing (..)

import Data.Decode exposing (decode)
import Data.Activity exposing (..)
import Data.Encode exposing (encode)
import Data.File exposing (..)
import Data.Model exposing (..)
import Data.Palette exposing (..)
import Dict exposing (Dict)
import Dom
import Json.Encode
import Keyboard.Combo
import Messages exposing (..)
import Random.Pcg
import Task
import Uuid


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, newCmds ) =
            case msg of
                NoOp ->
                    model ! []

                Data dataMsg ->
                    updateData dataMsg model

                Ui uiMsg ->
                    updateUi uiMsg model

                OpenProjectPort payload ->
                    decode (createModel model.currentSeed model.currentUuid) payload ! []

                SaveProjectPort payload ->
                    model ! []

                UpdateFilePort payload ->
                    { model | fileContents = Just payload } ! []

                NewUuid ->
                    let
                        ( newUuid, newSeed ) =
                            Random.Pcg.step Uuid.uuidGenerator model.currentSeed
                    in
                        { model
                            | currentUuid = newUuid
                            , currentSeed = newSeed
                        }
                            ! []
    in
        newModel ! [ newCmds, writeMetaPort (encode newModel) ]


updateData : DataMsg -> Model -> ( Model, Cmd Msg )
updateData msg model =
    case msg of
        AddCharacter ->
            addFile model Characters <|
                File "New Character" <|
                    CharacterFile <|
                        Character []

        AddLocation ->
            addFile model Locations <|
                File "New Location" <|
                    LocationFile

        AddScene ->
            addFile model Manuscript <|
                File "New Scene" <|
                    SceneFile <|
                        Scene "" Draft [] 999 (Dict.fromList []) [] Nothing

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
                ! []

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
                            ! []

                    Nothing ->
                        model ! []


updateUi : UiMsg -> Model -> ( Model, Cmd Msg )
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
                -- |> update (Ui ClosePalette)
                !
                    []

        ClosePalette ->
            { model | palette = Closed } ! []

        Combos comboMsg ->
            let
                ( updatedCombos, comboCmd ) =
                    Keyboard.Combo.update comboMsg model.keyCombos
            in
                ( { model | keyCombos = updatedCombos }, comboCmd )

        FocusPaletteInput msg ->
            model ! []

        OpenFile fileId ->
            { model
                | activeFile = Just fileId
                , openFiles =
                    if not <| List.member fileId model.openFiles then
                        fileId :: model.openFiles
                    else
                        model.openFiles
            }
                -- |> update (Ui ClosePalette)
                !
                    [ requestFilePort fileId ]

        SearchName search ->
            { model | palette = Files search } ! []

        SetPalette palette ->
            { model | palette = palette }
                ! [ Task.attempt (Ui << FocusPaletteInput) (Dom.focus "palette-input") ]

        SetActivity activity ->
            { model | activity = Just activity }
                -- |> update (Ui ClosePalette)
                !
                    []


addFile model activity file =
    let
        withFile =
            { model
                | files =
                    Dict.insert
                        (Uuid.toString model.currentUuid)
                        file
                        model.files
            }

        ( withOpenFile, cmdsOpenFile ) =
            withFile |> update (Ui <| OpenFile (Uuid.toString model.currentUuid))

        ( withNewUuid, cmdsNewUuid ) =
            withOpenFile |> update NewUuid

        ( withActivity, cmdsActivity ) =
            withNewUuid |> update (Ui <| SetActivity activity)
    in
        withActivity ! [ cmdsOpenFile, cmdsNewUuid, cmdsActivity ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openProjectPort OpenProjectPort
        , saveProjectPort SaveProjectPort
        , updateFilePort UpdateFilePort
        , Keyboard.Combo.subscriptions model.keyCombos
        ]



-- PORTS
-- port createFilePort : FileId -> Cmd msg


port openProjectPort : (String -> msg) -> Sub msg


port saveProjectPort : (String -> msg) -> Sub msg


port writeMetaPort : Json.Encode.Value -> Cmd msg


port requestFilePort : FileId -> Cmd msg


port updateFilePort : (String -> msg) -> Sub msg


port writeFilePort : { fileId : FileId, contents : String } -> Cmd msg
