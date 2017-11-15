module Views.Workspace.Character exposing (view)

import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Styles exposing (..)
import Messages exposing (..)


view : Dict FileId File -> FileId -> File -> Character -> Element Styles Variations Msg
view characters fileId file character =
    el NoStyle
        [ width fill
        , height fill
        , paddingTop <| innerScale 4
        , paddingRight <| innerScale 6
        , paddingBottom <| innerScale 4
        , paddingLeft <| innerScale 6
        ]
    <|
        column (Workspace CharacterEditor)
            [ width fill, height fill, spacing <| outerScale 3 ]
            [ viewName fileId file
            , viewAliases file character
            , viewDescription
            , viewRelationships (except characters fileId)
            ]


viewName fileId file =
    el (Workspace CharacterEditorTitle) [] <|
        Input.text InputText
            [ padding (innerScale 2)
            , vary Light True
            ]
            { onChange = Data << RenameFile fileId
            , value = file.name
            , label = Input.hiddenLabel "Name"
            , options = [ Input.textKey fileId ]
            }


viewAliases file character =
    column NoStyle
        [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
    <|
        [ el NoStyle [] <| text "Also known as:" ]
            ++ (List.map (input "Alias") character.aliases)
            ++ [ input "New Alias" "" ]


viewDescription =
    column NoStyle
        [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
        [ el NoStyle [] <| text "Description"
        , multiline "Description" ""
        ]


viewRelationships otherCharacters =
    column NoStyle
        [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
        [ el NoStyle [] <| text "Relationships"
        , wrappedRow NoStyle
            [ spacing <| innerScale 2 ]
            (List.map (\( id, file ) -> el Link [] <| text file.name)
                (Dict.toList otherCharacters)
            )
        ]


input label value =
    Input.text InputText
        [ padding <| innerScale 2 ]
        { onChange = (\s -> NoOp)
        , value = value
        , label = Input.hiddenLabel label
        , options = []
        }


multiline label value =
    Input.multiline InputText
        [ padding <| innerScale 2, height (px (fontScale 8)) ]
        { onChange = (\s -> NoOp)
        , value = value
        , label = Input.hiddenLabel label
        , options = []
        }
