module Binder.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root
    | Folder
    | File


css =
    (stylesheet << namespace "binder")
        [ Css.class Root [ height (pct 100) ]
        , Css.class Folder [ marginBottom (em 1) ]
        , Css.class File [ padding (em 1) ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "binder"
