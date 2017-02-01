port module Editor.State exposing (init, update, subscriptions)

import Json.Encode
import Json.Decode
import Editor.Types exposing (..)
import Editor.Decode
import Scene.State
import Debug


init : ( Model, Cmd Msg )
init =
    ( { name = "A Scribe of Sol"
      , author = "Laurence Roberts"
      , manuscript = []
      , plan = []
      , notes = []
      , open = []
      , active = Nothing
      }
    , Cmd.none
    )


port showOpenDialog : () -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowOpenDialog ->
            ( model, showOpenDialog () )

        OpenProject metaData ->
            ( Editor.Decode.decodeMetaData metaData, Cmd.none )


port openProject : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    openProject OpenProject
