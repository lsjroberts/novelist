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
    | BinderDirectory
    | BinderDirectoryIcon
    | BinderEntries
    | BinderFile
    | BinderHeader
    | BinderIcon
    | BinderWrapper
    | Editor
    | EditorWrapper
    | Footer
    | FooterCommit
    | FooterWordCount
    | FooterWordTarget
    | Inspector
    | Menu
    | Panel
    | Scene
    | SceneContent
    | SceneContentEditor
    | SceneContentEditorArticle
    | SceneDebug
    | SceneHeading
    | SceneParentHeading
    | TokenEmphasis
    | TokenParagraph
    | TokenSpeech
    | TokenWrap
    | Workspace
    | WorkspaceHeader
    | WorkspaceHeaderAuthor


css =
    (stylesheet << namespace "")
        [ Css.class Root
            [ fontFamilies [ "Quicksand" ]
            , fontWeight lighter
            , backgroundColor (hex "#fdf6e3")
            , color (hex "#333333")
            , overflow hidden
            , height (pct 100)
            ]
        , Css.class Binder
            [ position fixed
            , height (pct 100)
            , lineHeight (num 1.75)
            ]
        , Css.class BinderDirectory
            [ paddingLeft (em 1.05) ]
        , Css.class BinderDirectoryIcon
            [ display inlineBlock
            , marginRight (em 0.25)
            , marginLeft (em -1.05)
            , width (em 0.8)
            , verticalAlign middle
            , textAlign center
            ]
        , Css.class BinderEntries []
        , Css.class BinderFile
            [ paddingLeft (em 1.05) ]
        , Css.class BinderHeader []
        , Css.class BinderIcon
            [ marginRight (em 0.5)
            , verticalAlign middle
            , textAlign center
            ]
        , Css.class BinderWrapper
            [ width (pct 20) ]
        , Css.class Editor
            [ displayFlex
            , property "justify-content" "space-between"
            , height (pct 100)
            , overflow scroll
            ]
        , Css.class EditorWrapper
            [ height (pct 100)
            , displayFlex
            , flexDirection column
            ]
        , Css.class Footer
            [ backgroundColor (rgba 235 235 235 0.3)
              -- , height (px 38)
              -- , padding2 (em 0) ((pct 20) + (em 2))
            , property "padding" "1em calc(20% + 2em)"
            , displayFlex
            , property "justify-content" "space-between"
            ]
        , Css.class FooterCommit
            []
        , Css.class FooterWordCount
            []
        , Css.class FooterWordTarget
            [ backgroundColor transparent
            , padding (px 0)
            , border (px 0)
            , borderBottom3 (px 1) dotted (rgba 0 0 0 0.3)
            , outline none
            , fontFamilies [ "Quicksand" ]
            , fontSize (em 1)
            , fontWeight (int 300)
            ]
        , Css.class Inspector
            [ width (pct 20) ]
        , Css.class Menu
            [ backgroundColor (rgba 235 235 235 0.3)
            , height (px 38)
            ]
        , Css.class Panel
            [ backgroundColor (rgba 245 245 245 0.3)
            , height (pct 100)
            , padding (px 34)
            ]
        , Css.class Scene
            [ paddingTop (px 72)
            , fontFamilies [ "Cochin" ]
            ]
        , Css.class SceneContent
            [ maxWidth (em 31)
            , margin auto
            , fontSize (em (18 / 16))
            , lineHeight (num 1.4)
            ]
        , Css.class SceneContentEditor
            [ height (pct 100)
            , minHeight (pct 100)
            ]
        , Css.class SceneContentEditorArticle
            [ outline none
            ]
        , Css.class SceneDebug
            [ fontFamilies [ "Fira Code" ]
            , lineHeight (em 1.6)
            ]
        , Css.class SceneHeading
            [ backgroundColor transparent
            , marginBottom (em 1)
            , padding (px 0)
            , border (px 0)
            , outline none
            , width (pct 100)
            , fontFamilies [ "Cochin" ]
            , fontSize (em 3)
            , textAlign center
            ]
        , Css.class SceneParentHeading
            [ marginBottom (em 0.5)
            , padding (px 0)
            , border (px 0)
            , outline none
            , width (pct 100)
            , fontFamilies [ "Cochin" ]
            , fontSize (em 2)
            , textAlign center
            , color (hex "#666666")
            ]
        , Css.class TokenEmphasis
            [ fontStyle italic
            ]
        , Css.class TokenParagraph
            [ marginTop (em 0)
            , marginBottom (em 0.5)
            , textIndent (em 1)
            ]
        , Css.class TokenSpeech
            [ color (hex "268bd2")
            ]
        , Css.class TokenWrap
            [ display none ]
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
