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
    | SceneEditor
    | TabBar
    | Tab


type Variations
    = Active
    | Light


styleSheet theme =
    Style.styleSheetWith
        [ unguarded ]
        [ style NoStyle []
        , style Body
            [ Color.text (.text theme)
            , Color.background (.background theme)
            ]
        , style (Activity ActivityWrapper) <|
            (panelStyles theme)
                ++ [ Border.right 1 ]
        , style (Activity ActivityItem)
            [ cursor "pointer"
            , hover [ Color.background (.active theme) ]
            , variation Active
                [ Color.background (.active theme) ]
            ]
        , style (Explorer ExplorerWrapper) <|
            (panelStyles theme)
                ++ [ Border.right 1 ]
        , style (Explorer Group)
            [ Font.size <| fontScale 2 ]
        , style (Explorer ExplorerFolder)
            [ Font.size <| fontScale 1 ]
        , style (Explorer ExplorerFile)
            [ cursor "pointer"
            , hover [ Color.background (.active theme) ]
            , variation Active
                [ Color.background (.active theme) ]
            ]
        , style (Explorer ExplorerHeaderAction)
            [ cursor "pointer"
            , hover [ Color.background (.active theme) ]
            ]
        , style InputText
            [ Color.background (.active theme)
            , Color.text (.text theme)
            , focus
                [ Shadow.box { offset = ( 0, 0 ), size = 0, blur = 0, color = Color.black }
                ]
            , variation Light
                [ Color.background (.background theme)
                , Color.border (.active theme)
                , Border.bottom 1
                , hover [ Color.background (.background theme) ]
                , focus
                    [ Color.background (.background theme)
                    , Color.border (.text theme)
                    , Shadow.box { offset = ( 0, 0 ), size = 0, blur = 0, color = Color.black }
                    ]
                ]
            ]
        , style Link
            [ Color.text (.link theme)
            , cursor "pointer"
            , Font.underline
            ]
        , style (Meta MetaWrapper) <|
            (panelStyles theme)
                ++ [ Border.left 1 ]
        , style (Meta MetaHeading)
            [ Font.size <| fontScale 2 ]
        , style (Meta MetaStatus)
            [ Border.rounded 100
            , Color.background (.secondary theme)
            ]
        , style (Meta MetaTag)
            [ Border.rounded 100
            , Color.background (.primary theme)
            ]
        , style (Palette PaletteWrapper)
            [ Color.background (.background theme)
            , Color.border (.active theme)
            , Border.all 1
            , Shadow.simple
            , Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
        , style (Palette PaletteItem)
            [ Color.text (.text theme)
            , cursor "pointer"
            , hover [ Color.background (.active theme) ]
            ]
        , style Placeholder
            [ Color.background (.primary theme) ]
        , style (StatusBar StatusBarWrapper)
            [ Color.background (.active theme)
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
        , style (Workspace SceneEditor)
            []
        , style (Workspace TabBar)
            [ Border.bottom 1
            , Color.border (.active theme)
            , Color.background (.backgroundSecondary theme)
              -- , Shadow.box { offset = ( 0, 2 ), size = 0, blur = 2, color = rgba 0 0 0 0.05 }
            ]
        , style (Workspace Tab)
            [ Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.text (.text theme)
            , Color.border (.active theme)
            , cursor "pointer"
            , hover [ Color.background (.active theme) ]
            , variation Active
                [ Color.text (.text theme)
                , Color.background (.active theme)
                ]
            ]
        ]


panelStyles theme =
    [ Color.background (.backgroundSecondary theme)
    , Color.border (.active theme)
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


fontScale =
    Scale.modular 13 1.3


innerScale =
    Scale.modular 4 2


outerScale =
    Scale.modular 13 1.3
