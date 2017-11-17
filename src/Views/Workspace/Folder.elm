module Views.Workspace.Folder exposing (view)

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


view : Dict FileId File -> FileId -> File -> Element Styles Variations Msg
view files fileId file =
    el NoStyle
        [ width fill
        , height fill
        , paddingTop <| innerScale 4
        , paddingRight <| innerScale 6
        , paddingBottom <| innerScale 4
        , paddingLeft <| innerScale 6
        ]
    <|
        column NoStyle
            [ width fill, height fill, spacing <| outerScale 3 ]
            [ viewName fileId file
            , viewFiles fileId files
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


viewFiles fileId files =
    let
        showFiles =
            files
                |> Dict.filter (\_ file -> file.parentId == Just fileId)
                |> Dict.map viewFile
                |> Dict.values
    in
        column NoStyle [ spacing <| outerScale 1 ] showFiles


viewFile fileId file =
    el Link [ onClick (Ui <| OpenFile fileId) ] <| text file.name
