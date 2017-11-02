module Styles exposing (..)

import Color exposing (rgb, rgba)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Scale as Scale


type Styles
    = NoStyle
    | Activity ActivityStyle
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
        , style (Activity ActivityItem) <|
            [ cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            , variation Active
                [ Color.background (rgb 229 229 229) ]
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
            , hover [ Color.background (rgb 229 229 229) ]
            , variation Active
                [ Color.background (rgb 229 229 229) ]
            ]
        , style (Explorer ExplorerHeaderAction)
            [ cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            ]
        , style InputText
            [ Color.background (rgb 229 229 229)
            , variation Light
                [ Color.background (rgb 255 255 255)
                , Color.border (rgb 229 229 229)
                , Border.bottom 1
                , hover [ Color.background (rgb 241 241 241) ]
                , focus [ Color.background (rgb 241 241 241) ]
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
        , style Placeholder
            [ Color.background (rgb 241 200 200) ]
        , style (StatusBar StatusBarWrapper)
            [ Color.background (rgb 229 229 229)
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
            , Color.border (rgb 229 229 229)
            , Color.background (rgb 241 241 241)
              -- , Shadow.box { offset = ( 0, 2 ), size = 0, blur = 2, color = rgba 0 0 0 0.05 }
            ]
        , style (Workspace Tab)
            [ Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.text (rgb 170 170 170)
            , Color.border (rgb 229 229 229)
            , cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            , variation Active
                [ Color.text (rgb 0 0 0)
                , Color.background (rgb 229 229 229)
                ]
            ]
        ]


panelStyles =
    [ Color.background (rgb 241 241 241)
    , Color.border (rgb 229 229 229)
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


uiColor : UiColor -> Color.Color
uiColor color =
    case color of
        PrimaryColor ->
            rgb 0 0 0

        SecondaryColor ->
            rgb 0 0 0

        TertiaryColor ->
            rgb 0 0 0


fontScale =
    Scale.modular 13 1.3


paddingScale =
    Scale.modular 4 2


spacingScale =
    Scale.modular 13 1.3
