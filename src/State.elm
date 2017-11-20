port module State exposing (..)

import Data.Decode exposing (decode)
import Data.Activity as Activity
import Data.Encode exposing (encode)
import Data.File exposing (..)
import Data.Model exposing (..)
import Data.Palette exposing (..)
import Data.Search exposing (..)
import Dict exposing (Dict)
import Html5.DragDrop as DragDrop
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

                OpenProjectSubscription payload ->
                    decode (createModel model.currentSeed model.currentUuid) payload ! []

                UpdateFileSubscription payload ->
                    { model | fileContents = Just payload } ! []

                SearchSubscription payload ->
                    case model.search of
                        Just search ->
                            { model
                                | search =
                                    Just
                                        { search
                                            | result =
                                                { contents = Just (decodeSearchContents payload)
                                                }
                                        }
                            }
                                ! []

                        Nothing ->
                            model ! []

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

                DragDropFiles dragDropMsg ->
                    let
                        ( dragDropModel, dragDropResult ) =
                            DragDrop.update dragDropMsg model.dragDropFiles
                    in
                        { model
                            | dragDropFiles = dragDropModel
                            , files =
                                case dragDropResult of
                                    Nothing ->
                                        model.files

                                    Just ( dragFileId, dropFileId ) ->
                                        if isFolder dropFileId model.files then
                                            setParent dropFileId dragFileId model.files
                                        else
                                            placeAfter dropFileId dragFileId model.files
                        }
                            ! []
    in
        case msg of
            Data _ ->
                newModel ! [ newCmds, writeMetaPort (encode newModel) ]

            _ ->
                newModel ! [ newCmds ]


updateData : DataMsg -> Model -> ( Model, Cmd Msg )
updateData msg model =
    case msg of
        AddCharacter parent ->
            addFile model Activity.Characters <|
                File "New Character" parent (nextPosition (children parent (characters model.files))) <|
                    CharacterFile <|
                        Character []

        AddCharacterFolder ->
            addFile model Activity.Characters <|
                File "New Group" Nothing (nextPosition (children Nothing (scenes model.files))) <|
                    FolderFile CharacterFolder

        AddLocation parent ->
            addFile model Activity.Locations <|
                File "New Location" parent (nextPosition (children parent (locations model.files))) <|
                    LocationFile

        AddLocationFolder ->
            addFile model Activity.Locations <|
                File "New Group" Nothing (nextPosition (children Nothing (locations model.files))) <|
                    FolderFile LocationFolder

        AddScene parent ->
            addFile model Activity.Manuscript <|
                File "New Scene" parent (nextPosition (children parent (scenes model.files))) <|
                    SceneFile <|
                        Scene "" Draft [] (Dict.fromList []) [] Nothing

        AddSceneFolder ->
            addFile model Activity.Manuscript <|
                File "New Part" Nothing (nextPosition (children Nothing (scenes model.files))) <|
                    FolderFile SceneFolder

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

        Search term ->
            { model
                | search =
                    Just
                        (FileSearch term
                            { contents = Nothing
                            }
                        )
            }
                ! [ searchPort term ]

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
        [ openProjectSubscription OpenProjectSubscription
        , updateFileSubscription UpdateFileSubscription
        , searchSubscription SearchSubscription
        , Keyboard.Combo.subscriptions model.keyCombos
        ]



-- PORTS
-- port createFilePort : FileId -> Cmd msg


port openProjectSubscription : (String -> msg) -> Sub msg


port updateFileSubscription : (String -> msg) -> Sub msg


port searchPort : String -> Cmd msg


port searchSubscription : (String -> msg) -> Sub msg


port writeMetaPort : Json.Encode.Value -> Cmd msg


port requestFilePort : FileId -> Cmd msg


port writeFilePort : { fileId : FileId, contents : String } -> Cmd msg
