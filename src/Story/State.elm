module Story.State exposing (init, update, subscriptions)

import Response exposing (..)
import Story.Types exposing (..)
import Scene.State


init : ( Model, Cmd Msg )
init =
    let
        scenes =
            [ Scene.State.namedWithChildren "Fellowship of the Ring"
                [ "Prologue"
                , "Chapter One"
                , "Chapter Two"
                , "Chapter Three"
                ]
            , Scene.State.namedWithChildren "The Two Towers"
                [ "Chapter Four"
                , "Chapter Five"
                ]
            , Scene.State.namedWithChildren "Return of the King"
                [ "Chapter Six"
                , "Chapter Seven"
                ]
            ]
    in
        ( Model scenes, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
