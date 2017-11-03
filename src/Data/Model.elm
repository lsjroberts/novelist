module Data.Model exposing (..)

import Data.Activity exposing (Activity(..))
import Data.File exposing (..)
import Dict exposing (Dict)
import Messages exposing (Msg(..))
import Random.Pcg exposing (Seed)
import Uuid exposing (Uuid)


type alias Model =
    { currentSeed : Seed
    , currentUuid : Uuid
    , files : Dict FileId File
    , activity : Activity
    , openFiles : List FileId
    , activeFile : Maybe FileId
    , renamingFile : Maybe FileId
    }


init : Int -> ( Model, Cmd Msg )
init seed =
    let
        ( newUuid, newSeed ) =
            Random.Pcg.step Uuid.uuidGenerator (Random.Pcg.initialSeed seed)
    in
        ( { currentSeed = newSeed
          , currentUuid = newUuid
          , activity = Manuscript
          , files =
                (Dict.fromList
                    [ ( "0"
                      , File "Chapter One"
                            (SceneFile <|
                                Scene "Mr and Mrs Bennet have a conversation. Maecenas sed diam eget risus varius blandit sit amet non magna. Sed posuere consectetur est at lobortis."
                                    Draft
                                    [ "tag", "another tag", "one more", "further tags yay" ]
                                    0
                                    (Dict.fromList
                                        [ ( "4", SceneCharacter True )
                                        , ( "5", SceneCharacter True )
                                        , ( "6", SceneCharacter False )
                                        ]
                                    )
                                    []
                                    Nothing
                            )
                      )
                    , ( "1", File "Chapter Two" (SceneFile <| Scene "A dance" Draft [] 1 (Dict.fromList []) [] <| Just 2000) )
                    , ( "2", File "Chapter Three" (SceneFile <| Scene "" Draft [] 2 (Dict.fromList []) [] Nothing) )
                    , ( "3", File "Chapter Four" (SceneFile <| Scene "" Draft [] 3 (Dict.fromList []) [] Nothing) )
                    , ( "4", File "Mr. Bennet" (CharacterFile <| Character [ "Mr. Bennet, Esquire" ]) )
                    , ( "5", File "Mrs. Bennet" (CharacterFile <| Character []) )
                    , ( "6", File "Charles Bingley" (CharacterFile <| Character [ "Mr. Bingley", "Bingley" ]) )
                    ]
                )
          , openFiles = [ "0", "2", "4" ]
          , activeFile = (Just "0")
          , renamingFile = Nothing
          }
        , Cmd.none
        )
