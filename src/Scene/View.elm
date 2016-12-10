module Scene.View exposing (root)

import Css exposing (..)
import Json.Decode as Json
import Html exposing (Html, div, h1, article, p)
import Html.Attributes exposing (contenteditable, spellcheck)
import Html.Events exposing (on, onFocus)
import Html.Keyed
import Styles exposing (styles)
import Scene.Types exposing (..)
import Token.Types
import Token.View


root : Model -> Html Msg
root model =
    div
        [ styles
            [ margin2 (px 0) auto
            , width (pct 80)
            , maxWidth (em 44)
            ]
        ]
        [ nameView model
        , contentView model
        , Html.text ""
        ]



-- VIEWS


nameView : Model -> Html Msg
nameView model =
    h1
        [ styles
            [ marginTop (px 0)
            , marginBottom (px 40)
            , sceneFont
            , fontWeight normal
            , fontSize (px 48)
            , textAlign center
            ]
        ]
        [ Html.text model.name ]


contentView : Model -> Html Msg
contentView model =
    Html.Keyed.node "div"
        []
        [ ( toString model.commit
          , article
                [ styles
                    [ sceneFont
                    , fontSize (px 24)
                    ]
                , contenteditable True
                , spellcheck False
                , onFocus StartWriting
                , on "blur" (Json.map Write childrenContentDecoder)
                ]
                (List.map (\x -> Html.map TokenMsg (Token.View.root x)) model.content)
          )
        ]



-- <|
--     case model.isWriting of
--         True ->
--             [ contentAsStringView model.content ]
--
--         False ->
--             [ contentThruLensesView model.content ]
-- contentAsStringView : List Token.Types.Model -> Html msg
-- contentAsStringView tokens =
--     tokens
--         |> List.map (\x -> p [] [ Html.text x.value ])
--         |> div []
--
--
-- contentThruLensesView : List Token.Types.Model -> Html msg
-- contentThruLensesView tokens =
--     contentAsStringView tokens
-- STYLES


sceneFont =
    fontFamilies [ "Cochin", "Georgia", "serif" ]



-- DECODERS


targetTextContent : Json.Decoder String
targetTextContent =
    Json.at [ "target", "textContent" ] Json.string


childrenContentDecoder : Json.Decoder String
childrenContentDecoder =
    Json.at [ "target", "childNodes" ] (Json.keyValuePairs textContentDecoder)
        |> Json.map
            (\nodes ->
                nodes
                    |> List.filterMap
                        (\( key, text ) ->
                            case String.toInt key of
                                Err msg ->
                                    Nothing

                                Ok value ->
                                    Just text
                        )
                    |> List.foldl (\acc x -> acc ++ "\n" ++ x) ""
            )


textContentDecoder : Json.Decoder String
textContentDecoder =
    Json.oneOf [ Json.field "textContent" Json.string, Json.succeed "nope" ]
