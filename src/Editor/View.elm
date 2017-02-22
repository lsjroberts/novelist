module Editor.View exposing (root)

import Css exposing (..)
import Styles exposing (styles)
import Html exposing (Html, div, h1)
import Html.Events exposing (onClick)
import Editor.Types exposing (..)


root : Model -> Html Msg
root model =
    div [ styles [ height (pct 100) ] ]
        [ div
            [ styles
                [ height (pct 100) ]
            ]
            [ header model
              --tabBar model
            ]
        ]


header : Model -> Html Msg
header model =
    let
        name =
            div [] [ Html.text model.name ]

        author =
            div [ styles [ textAlign right ] ] [ Html.text model.author ]
    in
        div
            [ styles [ displayFlex, property "justify-content" "space-between" ] ]
            [ name, author ]


tabBar : Model -> Html Msg
tabBar model =
    div
        [ styles
            [ displayFlex
            ]
        ]
        []



-- <|
-- List.map (tab model.files) model.open
-- tab : List File -> FileId -> Html Msg
-- tab files openFileId =
--     div
--         [ styles
--             [ padding2 (em 1.4) (em 1)
--             , backgroundColor (hex "e2e7e9")
--             , fontSize (em 0.8)
--             , color (hex "48809e")
--             ]
--         ]
--         [ Html.text openFileId ]


viewManuscript : Model -> Html Msg
viewManuscript model =
    div
        [ styles
            [ position fixed
            , top (px 0)
            , left (px 0)
            , padding (px 32)
            , width (pct 20)
            , height (pct 100)
            , overflowY scroll
              -- , backgroundColor (hex "f5f5f5")
            , backgroundColor (hex "e2e7e9")
            , color (hex "48809e")
            ]
        ]
        [ h1
            [ styles
                [ marginBottom (em 1)
                , fontSize (px 18)
                , fontWeight (int 400)
                ]
            ]
            [ Html.text "Manuscript" ]
        ]
