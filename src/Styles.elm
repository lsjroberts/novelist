module Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Html.CssHelpers


styles : List Mixin -> Attribute msg
styles =
    Css.asPairs >> style


type CssClasses
    = Root
    | Binder
    | BinderFile
    | BinderWrapper
    | Editor
    | EditorWrapper
    | Inspector
    | Menu
    | Panel
    | Scene
    | SceneHeading
    | Workspace
    | WorkspaceHeader
    | WorkspaceHeaderAuthor


css =
    (stylesheet << namespace "")
        [ Css.class Root
            [ fontFamilies [ "Quicksand" ]
            , color (hex "#333333")
            , overflow hidden
            , height (pct 100)
            ]
        , Css.class Binder
            [ height (pct 100), lineHeight (int 2) ]
        , Css.class BinderFile
            [ marginBottom (em 1), paddingLeft (em 1) ]
        , Css.class BinderWrapper
            [ width (pct 20) ]
        , Css.class Editor
            [ displayFlex
            , property "justify-content" "space-between"
            , height (pct 100)
            ]
        , Css.class EditorWrapper
            [ height (pct 100) ]
        , Css.class Inspector
            [ width (pct 20) ]
        , Css.class Menu
            [ backgroundColor (rgba 235 235 235 1.0)
            , height (px 38)
            ]
        , Css.class Panel
            [ backgroundColor (rgba 245 245 245 1.0)
            , height (pct 100)
            , padding (px 34)
            ]
        , Css.class Scene
            [ paddingTop (px 72)
            , fontFamilies [ "Cochin" ]
            ]
        , Css.class SceneHeading
            [ marginBottom (em 1)
            , fontSize (em 3)
            , textAlign center
            ]
        , Css.class Workspace
            [ width (pct 60)
            , padding (px 34)
            ]
        , Css.class WorkspaceHeader
            [ displayFlex
            , property "justify-content" "space-between"
            , lineHeight (int 2)
            ]
        , Css.class WorkspaceHeaderAuthor
            [ textAlign right ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace ""
