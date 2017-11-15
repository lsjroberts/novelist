module Data.Model exposing (..)

import Data.Activity exposing (Activity(..))
import Data.File exposing (..)
import Data.Palette exposing (..)
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
    , theme = novelistDarkTheme
    }


init : Int -> ( Model, Cmd Msg )
init seed =
    let
        ( newUuid, newSeed ) =
            Random.Pcg.step Uuid.uuidGenerator (Random.Pcg.initialSeed seed)
    in
        ( testCharacters newUuid newSeed
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
            [ ( "0", File "Bob" <| CharacterFile { aliases = [ "Robert" ] } )
            , ( "1", File "Alice" <| CharacterFile { aliases = [] } )
            , ( "2", File "Sam" <| CharacterFile { aliases = [] } )
            ]
        )
        [ "0" ]
        (Just "0")
