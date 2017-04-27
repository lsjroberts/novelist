module Binder.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root
    | Folder
    | FolderName
    | File
    | Nested


css =
    (stylesheet << namespace "binder")
        [ Css.class Root [ height (pct 100), lineHeight (int 2) ]
        , Css.class File []
        , Css.class Nested [ marginBottom (em 1), paddingLeft (em 1) ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "binder"
