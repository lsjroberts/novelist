module Scene.State exposing (init, update, subscriptions)

import Scene.Types exposing (..)
import Token.Types
import Mocks.Austen exposing (prideAndPrejudice)


init : ( Model, Cmd Msg )
init =
    ( Model "Chapter 1"
        prideAndPrejudice
        (Children [])
        False
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Write content ->
            ( { model
                | content = Token.Types.markdownToTokens (Debug.log "WRITE" content)
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