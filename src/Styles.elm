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
    | BinderFileActive
    | BinderGroupIcon
    | BinderGroupTitle
    | BinderHeader
    | BinderIcon
    | BinderWrapper
    | Editor
    | EditorWrapper
    | Footer
    | FooterCommit
    | FooterWordCount
    | FooterWordTarget
    | FormInput
    | FormInputCheckbox
    | FormInputCheckboxChecked
    | FormInputCheckboxDisabled
    | FormInputDescription
    | FormInputLabel
    | FormInputOption
    | FormInputOptionInput
    | FormInputText
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
    | Settings
    | SettingsHeader
    | SettingsSection
    | SettingsSectionHeader
    | SettingsWrapper
    | TokenEmphasis
    | TokenParagraph
    | TokenSpeech
    | TokenWrap
    | Workspace
    | WorkspaceHeader
    | WorkspaceHeaderAuthor


colors =
    { primary = hex "#fdf6e3" }


css =
    (stylesheet << namespace "")
        [ Css.class Root
            [ fontFamilies [ "Quicksand" ]
            , fontWeight lighter
            , backgroundColor colors.primary
            , color (hex "#333333")
            , overflow hidden
            , height (pct 100)
            ]
        , Css.class Binder
            [ height (pct 100)
            , width (pct 100)
            , padding2 (em 0) (em 1)
            , lineHeight (num 1.75)
            ]
        , Css.class BinderDirectory
            [ paddingLeft (em 1.05)
            , marginTop (em 1)
            ]
        , Css.class BinderDirectoryIcon
            [ display inlineBlock
            , marginRight (em 0.8)
            , marginLeft (em -1.05)
            , width (em 0.8)
            , verticalAlign middle
            , textAlign center
            ]
        , Css.class BinderEntries []
        , Css.class BinderFile
            [ paddingLeft (em 1.05) ]
        , Css.class BinderFileActive
            [ backgroundColor (hex "51aae8")
            , color (hex "ffffff")
            ]
        , Css.class BinderGroupIcon
            [ display inlineBlock
            , marginRight (em 0.8)
            , height (px 28)
            , verticalAlign middle
            , textAlign center
            , color (hex "ffffff")
            ]
        , Css.class BinderGroupTitle
            [ backgroundColor (hex "268bd2")
            , fontSize (em 1.2)
            , margin2 (em 0) (em -1)
            , padding2 (em 0.3) (em 1)
            , color (hex "ffffff")
            ]
        , Css.class BinderHeader []
        , Css.class BinderIcon
            [ marginRight (em 0.5)
            , verticalAlign middle
            , textAlign center
            ]
        , Css.class BinderWrapper
            [ width (pct 20)
            ]
        , Css.class Editor
            [ displayFlex
            , property "justify-content" "space-between"
            , height (pct 100)
            , overflow hidden
            ]
        , Css.class EditorWrapper
            [ height (pct 100)
            , displayFlex
            , flexDirection column
            ]
        , Css.class Footer
            [ -- backgroundColor (rgba 235 235 235 0.3)
              -- , height (px 38)
              -- , padding2 (em 0) ((pct 20) + (em 2))
              property "padding" "1em calc(20% + 2em)"
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
        , Css.class FormInput
            [ margin2 (em 3) (em 0) ]
        , Css.class FormInputCheckbox
            [ border3 (px 1) solid (rgba 96 125 139 1)
            , borderRadius (px 2)
            , backgroundColor transparent
            , width (em 1)
            , height (em 1)
            , color (hex "#ffffff")
            , textAlign center
            ]
        , Css.class FormInputCheckboxChecked
            [ backgroundColor (rgba 96 125 139 1) ]
        , Css.class FormInputCheckboxDisabled
            [ backgroundColor (rgba 0 0 0 0.1)
            , borderColor (rgba 0 0 0 0.1)
            ]
        , Css.class FormInputDescription
            [ margin2 (em 0.3) (em 0)
            , fontSize (em 0.8)
            , opacity (num 0.5)
            ]
        , Css.class FormInputLabel
            [ fontWeight bold
            , fontSize (em 0.9)
            ]
        , Css.class FormInputOption
            [ margin2 (em 3) (em 0)
            , cursor pointer
            ]
        , Css.class FormInputOptionInput
            [ float left
            , paddingRight (em 2)
            , height (em 2)
            ]
        , Css.class FormInputText
            [ padding2 (em 0.8) (em 2)
            , border (px 0)
            , borderBottom3 (px 1) solid (rgba 96 125 139 0.2)
            , outline none
            , width (pct 100)
            , backgroundColor transparent
            , fontFamilies [ "Quicksand" ]
            , fontSize (em 1)
            ]
        , Css.class Inspector
            [ width (pct 20) ]
        , Css.class Menu
            [ height (px 38)
            ]
        , Css.class Panel
            [ height (pct 100)
            , width (pct 100)
            , padding2 (px 34) (px 0)
            ]
        , Css.class Scene
            [ padding2 (px 72) (px 0)
              -- , margin (px 10)
            , fontFamilies [ "Cochin" ]
              -- , boxShadow4 (px 0) (px 2) (px 3) (rgba 0 0 0 0.1)
              -- , backgroundColor colors.primary
            ]
        , Css.class SceneContent
            [ maxWidth (em 26)
            , margin auto
            , fontSize (em (18 / 16))
            , lineHeight (num 1.6)
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
            [ backgroundColor transparent
            , marginBottom (em 0.5)
            , padding (px 0)
            , border (px 0)
            , outline none
            , width (pct 100)
            , fontFamilies [ "Cochin" ]
            , fontSize (em 2)
            , textAlign center
            , color (hex "#666666")
            ]
        , Css.class Settings
            [ margin auto
            , padding2 (em 2) (em 0)
            , height (pct 100)
            , width (pct 60)
            , overflow scroll
            ]
        , Css.class SettingsHeader
            [ fontSize (em 2) ]
        , Css.class SettingsSection
            [ margin2 (em 4) (em 0)
            ]
        , Css.class SettingsSectionHeader
            [ fontSize (em 1.4)
            ]
        , Css.class SettingsWrapper
            [ height (pct 100)
            ]
        , Css.class TokenEmphasis
            [ fontStyle italic
            ]
        , Css.class TokenParagraph
            [ marginTop (em 0)
            , marginBottom (em 0.2)
            , textIndent (em 1)
            ]
        , Css.class TokenSpeech
            [ color (hex "268bd2")
            ]
        , Css.class TokenWrap
            [ display none ]
        , Css.class Workspace
            [ height (pct 100)
            , width (pct 60)
              -- , padding (px 34)
              -- , backgroundColor (rgba 235 235 235 0.3)
              -- , boxShadow5 inset (px 0) (px 2) (px 3) (rgba 0 0 0 0.1)
              -- , borderRadius (px 2)
            , overflow scroll
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
