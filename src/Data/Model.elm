module Data.Model exposing (..)

import Data.Activity exposing (Activity(..))
import Data.File exposing (..)
import Data.Palette exposing (..)
import Data.Prose exposing (..)
import Data.Search exposing (FileSearch)
import Data.Theme exposing (..)
import Dict exposing (Dict)
import Html5.DragDrop as DragDrop
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
    , prose : Maybe Prose
    , palette : PaletteStatus
    , keyCombos : Keyboard.Combo.Model Msg
    , theme : Theme
    , search : Maybe FileSearch
    , dragDropFiles : DragDrop.Model FileId FileId
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
    , prose = Nothing
    , keyCombos =
        Keyboard.Combo.init
            [ Keyboard.Combo.combo2 ( Keyboard.Combo.command, Keyboard.Combo.p )
                (Ui <| SetPalette (Files ""))
            ]
            (Ui << Combos)
    , theme = novelistLightTheme
    , search = Nothing
    , dragDropFiles = DragDrop.init
    }


init : Int -> ( Model, Cmd Msg )
init seed =
    let
        ( newUuid, newSeed ) =
            Random.Pcg.step Uuid.uuidGenerator (Random.Pcg.initialSeed seed)
    in
        ( testEditor newUuid newSeed
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
            [ ( "0", File "Bob" Nothing 0 <| CharacterFile { aliases = [ "Robert" ] } )
            , ( "1", File "Alice" Nothing 1 <| CharacterFile { aliases = [] } )
            , ( "2", File "Sam" Nothing 2 <| CharacterFile { aliases = [] } )
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
                      , File "Prologue" Nothing 0 <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "1"
                      , File "One" (Just "3") 0 <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "2"
                      , File "Two" (Just "3") 1 <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "3", File "Part One" Nothing 1 (FolderFile SceneFolder) )
                    , ( "4"
                      , File "Three" (Just "5") 0 <|
                            SceneFile
                                { synopsis = ""
                                , status = Draft
                                , tags = []
                                , characters = Dict.fromList []
                                , locations = []
                                , wordTarget = Nothing
                                }
                      )
                    , ( "5", File "Part Two" Nothing 2 (FolderFile SceneFolder) )
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


testEditor newUuid newSeed =
    let
        model =
            testScenes newUuid newSeed

        paragraphs =
            [ "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.\n"
            , "However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered the rightful property of some one or other of their daughters."
            , "“My dear Mr. Bennet,” said his lady to him one day, “have you heard that Netherfield Park is let at last?”"
            , "Mr. Bennet replied that he had not."
            , "“But it is,” returned she; “for Mrs. Long has just been here, and she told me all about it.”"
            , "Mr. Bennet made no answer."
            , "“Do you not want to know who has taken it?” cried his wife impatiently."
            , "“You want to tell me, and I have no objection to hearing it.”"
            , "This was invitation enough."
            , "“Why, my dear, you must know, Mrs. Long says that Netherfield is taken by a young man of large fortune from the north of England; that he came down on Monday in a chaise and four to see the place, and was so much delighted with it, that he agreed with Mr. Morris immediately; that he is to take possession before Michaelmas, and some of his servants are to be in the house by the end of next week.”"
            , "“What is his name?”"
            , "“Bingley.”"
            ]
    in
        { model
            | activity = Just Data.Activity.Manuscript
            , fileContents = Just (String.join "\n" paragraphs)
            , prose = Just { paragraphs = paragraphs, activeParagraph = Just 0 }
        }
