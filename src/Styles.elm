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
    | Activity ActivityStyle
    | Palette PaletteStyle
    | Explorer ExplorerStyle
    | InputText
    | Meta MetaStyle
    | Placeholder
    | StatusBar StatusBarStyle
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


type WorkspaceStyle
    = CharacterEditor
    | CharacterEditorTitle
    | TabBar
    | Tab


type Variations
    = Active
    | Light


styleSheet =
    Style.styleSheet
        [ style (Activity ActivityWrapper) <|
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
            , variation Light
                [ Color.background (rgb 255 255 255)
                , Color.border (uiColor ActiveColor)
                , Border.bottom 1
                , hover [ Color.background (uiColor BackgroundColor) ]
                , focus [ Color.background (uiColor BackgroundColor) ]
                ]
            ]
        , style (Meta MetaWrapper) <|
            panelStyles
                ++ [ Border.left 1 ]
        , style (Meta MetaHeading)
            [ Font.size <| fontScale 2 ]
        , style (Meta MetaStatus)
            [ Border.rounded 100
            , Color.background (rgb 200 200 241)
            ]
        , style (Meta MetaTag)
            [ Border.rounded 100
            , Color.background (rgb 241 200 200)
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
            [ cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            ]
        , style Placeholder
            [ Color.background (rgb 241 200 200) ]
        , style (StatusBar StatusBarWrapper)
            [ Color.background (uiColor ActiveColor)
            , Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
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
            , Color.text (rgb 170 170 170)
            , Color.border (uiColor ActiveColor)
            , cursor "pointer"
            , hover [ Color.background (uiColor ActiveColor) ]
            , variation Active
                [ Color.text (rgb 0 0 0)
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
    | ActiveColor


uiColor : UiColor -> Color.Color
uiColor color =
    case color of
        PrimaryColor ->
            rgb 0 0 0

        SecondaryColor ->
            rgb 0 0 0

        TertiaryColor ->
            rgb 0 0 0

        BackgroundColor ->
            rgb 241 241 241

        ActiveColor ->
            rgb 229 229 229


fontScale =
    Scale.modular 13 1.3


innerScale =
    Scale.modular 4 2


outerScale =
    Scale.modular 13 1.3
