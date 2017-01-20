module Story.State exposing (init, update, subscriptions)

import Response exposing (..)
import Story.Types exposing (..)
import Scene.State


init : ( Model, Cmd Msg )
init =
    let
        sceneOne =
            Scene.State.named "Prologue"

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
        ( Model sceneOne scenes, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
