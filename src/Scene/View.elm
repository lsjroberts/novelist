module Scene.View exposing (root)

import Css exposing (..)
import Json.Decode as Json
import Html exposing (Html, div, h1, article)
import Html.Keyed
import Html.Attributes exposing (contenteditable, spellcheck)
import Html.Events exposing (on, onFocus)
import Styles exposing (..)
import Scene.Types exposing (..)
import Scene.Decoders exposing (..)
import Token.Types
import Token.View


root : Model -> Html Msg
root model =
    div
        [ styles
            [ paddingTop (px 72)
            , fontFamilies [ "Cochin" ]
            ]
        ]
        [ heading
        , content model
        ]


heading : Html Msg
heading =
    h1
        [ styles
            [ marginBottom (em 1)
            , fontSize (em 3)
            , textAlign center
            ]
        ]
        [ Html.text "Heading" ]


content : Model -> Html Msg
content model =
    div
        [ styles
            [ maxWidth (em 31)
            , margin auto
            , fontSize (em (18 / 16))
            , lineHeight (num 1.4)
            ]
        ]
        [ contentEditor model ]


contentEditor : Model -> Html Msg
contentEditor model =
    Html.Keyed.node "div"
        [ styles [ height (pct 100) ] ]
        [ ( toString model.commit
          , article
                [ styles
                    [ height (pct 100)
                    , outline none
                    ]
                , contenteditable True
                , spellcheck False
                , onFocus StartWriting
                , on "blur" (Json.map Write childrenContentDecoder)
                ]
                (List.map (\x -> Html.map TokenMsg (Token.View.root x)) model.content)
          )
        ]
