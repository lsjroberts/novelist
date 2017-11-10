module Styles exposing (..)

import Color exposing (rgb, rgba)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Scale as Scale
import Style.Shadow as Shadow


type Styles
    = NoStyle
    | Body
    | Activity ActivityStyle
    | Palette PaletteStyle
    | Explorer ExplorerStyle
    | InputText
    | Link
    | Meta MetaStyle
    | Placeholder
    | StatusBar StatusBarStyle
    | Welcome WelcomeStyle
    | Workspace WorkspaceStyle


type ActivityStyle
    = ActivityWrapper
    | ActivityItem


type ExplorerStyle
    = ExplorerWrapper
    | Group
    | ExplorerFolder
    | ExplorerFile
    | ExplorerHeaderAction


type MetaStyle
    = MetaWrapper
    | MetaHeading
    | MetaStatus
    | MetaTag


type PaletteStyle
    = PaletteWrapper
    | PaletteItem


type StatusBarStyle
    = StatusBarWrapper


type WelcomeStyle
    = WelcomeWrapper
    | WelcomeTitle
    | WelcomeHeading


type WorkspaceStyle
    = CharacterEditor
    | CharacterEditorTitle
    | TabBar
    | Tab


type Variations
    = Active
    | Light


styleSheet =
    Style.styleSheetWith
        [ unguarded ]
        [ style NoStyle []
        , style Body
            [ Color.text (uiColor TextColor)
            , Color.background (uiColor BackgroundColor)
            ]
        , style (Activity ActivityWrapper) <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Activity ActivityItem)
            [ cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            , variation Active
                [ Color.background (uiColor ActiveColor) ]
            ]
        , style (Explorer ExplorerWrapper) <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Explorer Group)
            [ Font.size <| fontScale 2 ]
        , style (Explorer ExplorerFolder)
            [ Font.size <| fontScale 1 ]
        , style (Explorer ExplorerFile)
            [ cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            , variation Active
                [ Color.background (uiColor ActiveColor) ]
            ]
        , style (Explorer ExplorerHeaderAction)
            [ cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            ]
        , style InputText
            [ Color.background (uiColor ActiveColor)
            , Color.text (uiColor TextColor)
            , variation Light
                [ Color.background (uiColor BackgroundColor)
                , Color.border (uiColor ActiveColor)
                , Border.bottom 1
                , hover [ Color.background (uiColor BackgroundColor) ]
                , focus [ Color.background (uiColor BackgroundColor) ]
                ]
            ]
        , style Link
            [ Color.text (uiColor LinkColor)
            , cursor "pointer"
            , Font.underline
            ]
        , style (Meta MetaWrapper) <|
            panelStyles
                ++ [ Border.left 1 ]
        , style (Meta MetaHeading)
            [ Font.size <| fontScale 2 ]
        , style (Meta MetaStatus)
            [ Border.rounded 100
            , Color.background (uiColor SecondaryColor)
            ]
        , style (Meta MetaTag)
            [ Border.rounded 100
            , Color.background (uiColor PrimaryColor)
            ]
        , style (Palette PaletteWrapper)
            [ Color.background (uiColor BackgroundColor)
            , Color.border (uiColor ActiveColor)
            , Border.all 1
            , Shadow.simple
            , Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
        , style (Palette PaletteItem)
            [ Color.text (uiColor TextColor)
            , cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            ]
        , style Placeholder
            [ Color.background (uiColor PrimaryColor) ]
        , style (StatusBar StatusBarWrapper)
            [ Color.background (uiColor ActiveColor)
            , Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
        , style (Welcome WelcomeWrapper)
            [ Font.typeface <| fontStack SansSerif ]
        , style (Welcome WelcomeTitle)
            [ Font.typeface <| fontStack Serif
            , Font.size <| fontScale 7
            ]
        , style (Welcome WelcomeHeading)
            [ Font.size <| fontScale 3 ]
        , style (Workspace CharacterEditor)
            [ Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
        , style (Workspace CharacterEditorTitle)
            [ Font.typeface <| fontStack Serif
            , Font.size <| fontScale 4
            ]
        , style (Workspace TabBar)
            [ Border.bottom 1
            , Color.border (uiColor ActiveColor)
            , Color.background (uiColor BackgroundColor)
              -- , Shadow.box { offset = ( 0, 2 ), size = 0, blur = 2, color = rgba 0 0 0 0.05 }
            ]
        , style (Workspace Tab)
            [ Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.text (uiColor TextSecondaryColor)
            , Color.border (uiColor ActiveColor)
            , cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            , variation Active
                [ Color.text (uiColor TextColor)
                , Color.background (uiColor ActiveColor)
                ]
            ]
        ]


panelStyles =
    [ Color.background (uiColor BackgroundColor)
    , Color.border (uiColor ActiveColor)
    , Font.typeface <| fontStack SansSerif
    , Font.size <| fontScale 1
    ]


type FontStack
    = SansSerif
    | Serif
    | Mono


fontStack stack =
    case stack of
        SansSerif ->
            [ Font.font "-apple-system"
            , Font.font "BlinkMacSystemFont"
            , Font.font "Segoe WPC"
            , Font.font "Segoe UI"
            , Font.font "HelveticaNeue-Light"
            , Font.font "Ubuntu"
            , Font.font "Droid Sans"
            , Font.font "sans-serif"
            ]

        Serif ->
            [ Font.font "Cochin" ]

        Mono ->
            [ Font.font "monospaced" ]


type UiColor
    = PrimaryColor
    | SecondaryColor
    | TertiaryColor
    | BackgroundColor
    | TextColor
    | TextSecondaryColor
    | ActiveColor
    | LinkColor


type alias Theme =
    { primary : Color.Color
    , secondary : Color.Color
    , tertiary : Color.Color
    , background : Color.Color
    , text : Color.Color
    , textSecondary : Color.Color
    , active : Color.Color
    , link : Color.Color
    }


uiColor : UiColor -> Color.Color
uiColor color =
    let
        theme =
            novelistDarkTheme
    in
        case color of
            PrimaryColor ->
                .primary theme

            SecondaryColor ->
                .secondary theme

            TertiaryColor ->
                .tertiary theme

            BackgroundColor ->
                .background theme

            TextColor ->
                .text theme

            TextSecondaryColor ->
                .textSecondary theme

            ActiveColor ->
                .active theme

            LinkColor ->
                .link theme


novelistLightTheme : Theme
novelistLightTheme =
    { primary = rgb 241 200 200
    , secondary = rgb 200 200 241
    , tertiary = rgb 200 200 241
    , background = rgb 241 241 241
    , text = rgb 30 30 30
    , textSecondary = rgb 170 170 170
    , active = rgb 229 229 229
    , link = rgb 241 50 50
    }


novelistDarkTheme : Theme
novelistDarkTheme =
    { primary = rgb 141 100 100
    , secondary = rgb 100 100 141
    , tertiary = rgb 100 100 141
    , background = rgb 40 44 52
    , text = rgb 220 220 220
    , textSecondary = rgb 200 200 200
    , active = rgb 80 88 104
    , link = rgb 209 154 102
    }


fontScale =
    Scale.modular 13 1.3


innerScale =
    Scale.modular 4 2


outerScale =
    Scale.modular 13 1.3
