module Views.Workspace.Prose exposing (view)

import Data.Prose
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Maybe.Extra
import Messages exposing (Msg)
import Styles exposing (..)


view : Data.Prose.Prose -> Element Styles Variations Msg
view prose =
    let
        paragraphs activeParagraph =
            List.indexedMap
                (\index s ->
                    paragraph (Workspace ProseEditorParagraph)
                        [ vary Active ((Just index) == activeParagraph)
                        , vary Inactive ((Just index) /= activeParagraph && Nothing /= activeParagraph)
                        , onClick (Messages.Prose <| Messages.SetActiveParagraph index)
                        ]
                        [ text s ]
                )
                >> textLayout NoStyle [ spacing <| innerScale 3 ]

        -- prose =
        --     case maybeFileContents of
        --         Just fileContents ->
        --             el NoStyle
        --                 [ width fill
        --                 , height fill
        --                 ]
        --                 (paragraphs fileContents)
        --         Nothing ->
        --             el NoStyle [] empty
    in
        column (Workspace Prose)
            [ spacing <| outerScale 2, yScrollbar, clipX ]
            [ h1 (Workspace ProseTitle) [ paddingTop <| innerScale 6 ] (text "Title")
            , el (Workspace ProseEditor)
                [ width fill
                , height fill
                , paddingTop <| innerScale 4
                , paddingRight <| innerScale 6
                , paddingBottom <| innerScale 4
                , paddingLeft <| innerScale 6
                ]
                (paragraphs prose.activeParagraph prose.paragraphs)
            ]
