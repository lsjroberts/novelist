module Scene.State exposing (init, initNamed, initNamedWithChildren, update, subscriptions)

import Scene.Types exposing (..)
import Token.Factories exposing (markdownToTokens)
import Mocks.Austen exposing (prideAndPrejudice)


init : ( Model, Cmd Msg )
init =
    ( Model "Chapter One"
        prideAndPrejudice
        0
        []
        (Children [])
        False
    , Cmd.none
    )


initNamed : String -> Model
initNamed name =
    Model name [] 0 [] (Children []) False


initNamedWithChildren : String -> List String -> Model
initNamedWithChildren name childrenNames =
    let
        cs =
            List.map initNamed childrenNames
    in
        Model name [] 0 [] (Children cs) False


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Write content ->
            ( { model
                | content = markdownToTokens (Debug.log "WRITE" content)
                , commit = model.commit + 1
                , history = ( model.commit, model.content ) :: model.history
                , isWriting = False
              }
            , Cmd.none
            )

        StartWriting ->
            ( { model | isWriting = True }, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
