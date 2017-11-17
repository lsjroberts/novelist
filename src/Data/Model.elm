module Data.Model exposing (..)

import Data.Activity exposing (Activity(..))
import Data.File exposing (..)
import Data.Palette exposing (..)
import Data.Search exposing (FileSearch)
import Data.Theme exposing (..)
import Dict exposing (Dict)
import Keyboard.Combo
import Messages exposing (Msg(..), UiMsg(..))
import Random.Pcg exposing (Seed)
import Uuid exposing (Uuid)


type alias Model =
    { currentSeed : Seed
    , currentUuid : Uuid
    , files : Dict FileId File
    , activity : Maybe Activity
    , openFiles : List FileId
    , activeFile : Maybe FileId
    , fileContents : Maybe String
    , palette : PaletteStatus
    , keyCombos : Keyboard.Combo.Model Msg
    , theme : Theme
    , search : Maybe FileSearch
    }


createModel : Random.Pcg.Seed -> Uuid -> Dict FileId File -> List FileId -> Maybe FileId -> Model
createModel seed uuid files openFiles activeFile =
    { currentSeed = seed
    , currentUuid = uuid
    , files = files
    , activity = Nothing
    , openFiles = openFiles
    , activeFile = activeFile
    , fileContents = Nothing
    , palette = Closed
    , keyCombos =
        Keyboard.Combo.init
            [ Keyboard.Combo.combo2 ( Keyboard.Combo.command, Keyboard.Combo.p )
                (Ui <| SetPalette (Files ""))
            ]
            (Ui << Combos)
    , theme = novelistLightTheme
    , search = Nothing
    }


init : Int -> ( Model, Cmd Msg )
init seed =
    let
        ( newUuid, newSeed ) =
            Random.Pcg.step Uuid.uuidGenerator (Random.Pcg.initialSeed seed)
    in
        ( testScenes newUuid newSeed
        , Cmd.none
        )


blankModel newUuid newSeed =
    createModel
        newSeed
        newUuid
        (Dict.fromList [])
        []
        Nothing


testCharacters newUuid newSeed =
    createModel
        newSeed
        newUuid
        (Dict.fromList
            [ ( "0", File "Bob" Nothing <| CharacterFile { aliases = [ "Robert" ] } )
            , ( "1", File "Alice" Nothing <| CharacterFile { aliases = [] } )
            , ( "2", File "Sam" Nothing <| CharacterFile { aliases = [] } )
            ]
        )
        [ "0" ]
        (Just "0")


testScenes newUuid newSeed =
    let
        model =
            createModel
                newSeed
                newUuid
                (Dict.fromList
                    [ ( "0"
                      , File "Prologue" Nothing <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , position = 0
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "1"
                      , File "One" (Just "3") <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , position = 0
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "2"
                      , File "Two" (Just "3") <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , position = 0
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "3", File "Part One" Nothing (FolderFile SceneFolder) )
                    , ( "4"
                      , File "Three" (Just "5") <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , position = 0
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "5", File "Part Two" Nothing (FolderFile SceneFolder) )
                    ]
                )
                [ "0" ]
                (Just "0")
    in
        { model | activity = Just Data.Activity.Manuscript }


testSearch newUuid newSeed =
    let
        model =
            testScenes newUuid newSeed
    in
        { model
            | activity = Just Data.Activity.Search
            , search =
                Just
                    (FileSearch
                        "Bennet"
                        { contents =
                            Just
                                (Dict.fromList
                                    [ ( "0", [ "Hello Mr. Bennet blah", "Lorem ipsum Bennet" ] )
                                    , ( "1", [ "Bennet said some stuff", "Lorem ipsum Bennet" ] )
                                    , ( "2", [ "Hello Mr. Bennet blah", "Lorem ipsum Bennet" ] )
                                    ]
                                )
                        }
                    )
        }
