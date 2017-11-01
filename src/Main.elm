module Main exposing (..)

import Color exposing (rgb, rgba)
import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (Html, program)
import Html.Attributes
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Scale as Scale
import Style.Shadow as Shadow
import Octicons as Icon


-- PROGRAM


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MSG


type Msg
    = NoOp



-- MODEL


type alias Model =
    Int


init : ( Model, Cmd Msg )
init =
    ( 0
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    Element.viewport styleSheet <|
        row NoStyle
            [ height (percent 100) ]
            [ viewActivityBar
            , viewExplorer
            , viewWorkspace
            , viewMetaPanel
            ]



-- VIEW ACTIVITY BAR


viewActivityBar =
    column (Activity ActivityWrapper)
        []
        [ viewActivityItem Icon.book True
        , viewActivityItem Icon.gistSecret False
        , viewActivityItem Icon.globe False
        , viewActivityItem Icon.search False
        , viewActivityItem Icon.gitBranch False
        , viewActivityItem Icon.checklist False
        ]


viewActivityItem icon isActive =
    largeIcon
        |> icon
        |> html
        |> el (Activity <| ActivityItem isActive) [ padding <| paddingScale 2 ]



-- VIEW EXPLORER


viewExplorer =
    column (Explorer ExplorerWrapper)
        [ width (px 240)
          -- , spacing <| spacingScale 3
        ]
        [ viewExplorerHeader
        , viewExplorerFolder "Chapter One"
            [ "Chapter One"
            , "Chapter Two"
            , "Chapter Three"
            , "Chapter Four"
            ]
        , row (Explorer (ExplorerFile False))
            [ paddingXY (paddingScale 3) (paddingScale 1)
            , spacing <| paddingScale 1
            ]
            [ smallIcon
                |> Icon.file
                |> html
                |> el NoStyle []
            , smallIcon
                |> Icon.plus
                |> html
                |> el NoStyle []
            ]
        ]


viewExplorerHeader =
    row NoStyle
        [ paddingXY (paddingScale 3) (paddingScale 2), spacing <| spacingScale 1 ]
        [ el NoStyle [] <| text "Manuscript"
        , row NoStyle
            [ alignRight, spacing <| spacingScale 1 ]
            [ smallIcon
                |> Icon.file
                |> html
                |> el (Explorer ExplorerHeaderAction) []
            , smallIcon
                |> Icon.fileDirectory
                |> html
                |> el (Explorer ExplorerHeaderAction) []
            ]
        ]



-- viewExplorerGroup label items =
--     column (Explorer Group)
--         [ spacing <| spacingScale 2 ]
--         [ el NoStyle [] <| text label
--         , viewExplorerFolder items
--         ]


viewExplorerFolder active items =
    column (Explorer ExplorerFolder) [] <|
        List.map (\item -> viewExplorerFile (item == active) item) items


viewExplorerFile isActive label =
    row (Explorer (ExplorerFile isActive))
        [ paddingXY (paddingScale 3) (paddingScale 1)
        , spacing <| paddingScale 1
        ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el NoStyle []
        , text label
        ]



-- VIEW WORKSPACE


viewWorkspace =
    column NoStyle
        [ width fill ]
        [ viewTabBar
        , viewEditor
        , viewStatusBar
        ]


viewTabBar =
    row (Workspace TabBar)
        []
        [ viewTab True Icon.file "Chapter One"
        , viewTab False Icon.file "Chapter Three"
        , viewTab False Icon.gistSecret "Mr Bennet"
        ]


viewTab active icon label =
    row
        (Workspace <| Tab active)
        [ paddingTop <| paddingScale 2
        , paddingBottom <| paddingScale 2
        , paddingLeft <| paddingScale 3
        , paddingRight <| paddingScale 3
        , spacing <| paddingScale 1
        ]
        [ smallIcon
            |> icon
            |> html
            |> el NoStyle []
        , text label
        ]


viewEditor =
    column NoStyle
        [ width fill
        , height fill
        , paddingLeft <| paddingScale 6
        , paddingTop <| paddingScale 4
        , paddingBottom <| paddingScale 4
        ]
        [ viewMonacoEditor
        ]


viewMonacoEditor =
    html <|
        Html.iframe
            [ Html.Attributes.src "http://localhost:8080/editor/editor.html"
            , Html.Attributes.style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "border", "none" )
                ]
            ]
            []



-- VIEW META PANEL


viewMetaPanel =
    column (Meta MetaWrapper)
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 4 ]
        [ column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Synopsis"
            , paragraph NoStyle [] <|
                [ text <|
                    "Mr & Mrs Bennet have a conversation. Sociis natoque penatibus et "
                        ++ "magnis dis parturient montes, nascetur ridiculus mus. Maecenas "
                        ++ "faucibus mollis interdum."
                ]
            ]
        , column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Characters"
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Mr. Bennet"
                , smallIcon
                    |> Icon.megaphone
                    |> html
                    |> el NoStyle []
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Mrs. Bennet"
                , smallIcon
                    |> Icon.megaphone
                    |> html
                    |> el NoStyle []
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Mrs. Long"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Mr. Bingley"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Sir William"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Lady Lucas"
                ]
            ]
        , column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Locations"
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.globe
                    |> html
                    |> el NoStyle []
                , text "Longbourn House"
                ]
            ]
        ]



-- STATUS BAR


viewStatusBar =
    row (StatusBar StatusBarWrapper)
        [ alignRight
        , spacing <| spacingScale 1
        , paddingXY (paddingScale 2) (paddingScale 1)
        ]
        [ el NoStyle [] <| text "500 / 2000 words"
        , el NoStyle [] <| text "2500 characters"
        , el NoStyle [] <| text "25%"
        , smallIcon |> Icon.gear |> html |> el NoStyle []
        ]



-- ICONS


smallIcon =
    Icon.defaultOptions
        |> Icon.color "black"
        |> Icon.size (fontScale 1 |> floor)


largeIcon =
    Icon.defaultOptions
        |> Icon.color "black"
        |> Icon.size (fontScale 4 |> floor)



-- STYLE


type Styles
    = NoStyle
    | Activity ActivityStyle
    | Explorer ExplorerStyle
    | Meta MetaStyle
    | StatusBar StatusBarStyle
    | Workspace WorkspaceStyle


type ActivityStyle
    = ActivityWrapper
    | ActivityItem Bool


type ExplorerStyle
    = ExplorerWrapper
    | Group
    | ExplorerFolder
    | ExplorerFile Bool
    | ExplorerHeaderAction


type MetaStyle
    = MetaWrapper
    | MetaHeading


type StatusBarStyle
    = StatusBarWrapper


type WorkspaceStyle
    = TabBar
    | Tab Bool


styleSheet =
    Style.styleSheet
        [ style (Activity ActivityWrapper) <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Activity (ActivityItem False)) <|
            [ cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            ]
        , style (Activity (ActivityItem True)) <|
            [ cursor "pointer"
            , Color.background (rgb 229 229 229)
            ]
        , style (Explorer ExplorerWrapper) <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Explorer Group)
            [ Font.size <| fontScale 2 ]
        , style (Explorer ExplorerFolder)
            [ Font.size <| fontScale 1 ]
        , style (Explorer (ExplorerFile False))
            [ cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            ]
        , style (Explorer (ExplorerFile True))
            [ cursor "pointer"
            , Color.background (rgb 229 229 229)
            ]
        , style (Explorer ExplorerHeaderAction)
            [ cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            ]
        , style (Meta MetaWrapper) <|
            panelStyles
                ++ [ Border.left 1 ]
        , style (Meta MetaHeading)
            [ Font.size <| fontScale 2 ]
        , style (StatusBar StatusBarWrapper)
            [ Color.background (rgb 229 229 229)
            , Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            ]
        , style (Workspace TabBar)
            [ Border.bottom 1
            , Color.border (rgb 229 229 229)
            , Color.background (rgb 241 241 241)
              -- , Shadow.box { offset = ( 0, 2 ), size = 0, blur = 2, color = rgba 0 0 0 0.05 }
            ]
        , style (Workspace (Tab False))
            [ Font.typeface <| fontStack SansSerif
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.text (rgb 170 170 170)
            , Color.border (rgb 229 229 229)
            , cursor "pointer"
            , hover [ Color.background (rgb 229 229 229) ]
            ]
        , style (Workspace (Tab True))
            [ Font.typeface (fontStack SansSerif)
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.border (rgb 229 229 229)
            , Color.background (rgb 229 229 229)
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



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
