module Data.Model exposing (..)

import Data.Activity exposing (Activity(..))
import Data.File exposing (..)
import Dict exposing (Dict)
import Set exposing (Set)
import Messages exposing (Msg(..))


type alias Model =
    { activity : Activity
    , files : Dict FileId File
    , openFiles : Set FileId
    , activeFile : Maybe FileId
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        Manuscript
        (Dict.fromList
            [ ( 0
              , File "Chapter One"
                    (SceneFile <|
                        Scene "Mr and Mrs Bennet have a conversation. Maecenas sed diam eget risus varius blandit sit amet non magna. Sed posuere consectetur est at lobortis."
                            "Draft"
                            [ "tag", "another tag", "one more", "further tags yay" ]
                            (Dict.fromList
                                [ ( 4, SceneCharacter True )
                                , ( 5, SceneCharacter True )
                                , ( 6, SceneCharacter False )
                                ]
                            )
                            []
                            Nothing
                    )
              )
            , ( 1, File "Chapter Two" (SceneFile <| Scene "A dance" "Draft" [] (Dict.fromList []) [] <| Just 2000) )
            , ( 2, File "Chapter Three" (SceneFile <| Scene "" "Draft" [] (Dict.fromList []) [] Nothing) )
            , ( 3, File "Chapter Four" (SceneFile <| Scene "" "Draft" [] (Dict.fromList []) [] Nothing) )
            , ( 4, File "Mr. Bennet" (CharacterFile <| Character [ "Mr. Bennet, Esquire" ]) )
            , ( 5, File "Mrs. Bennet" (CharacterFile <| Character []) )
            , ( 6, File "Charles Bingley" (CharacterFile <| Character [ "Mr. Bingley", "Bingley" ]) )
            ]
        )
        (Set.fromList [ 0, 2 ])
        (Just 0)
    , Cmd.none
    )
