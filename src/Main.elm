module Main exposing (..)

import Html exposing (Html, program)
import Html.Attributes
import Element exposing (..)
import Element.Attributes exposing (..)
import Style exposing (style)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Scale as Scale
import Style.Shadow as Shadow
import Color exposing (rgb, rgba)


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
    el ActivityBar [ width (px 50) ] (text "a")



-- VIEW EXPLORER


viewExplorer =
    column (Explorer ExplorerWrapper)
        [ width (px 240), padding <| paddingScale 3, spacing <| spacingScale 3 ]
        [ viewExplorerGroup "Manuscript" [ "Chapter One", "Chapter Two", "Chapter Three", "Chapter Four" ]
        , viewExplorerGroup "Characters" []
        , viewExplorerGroup "Locations" []
        ]


viewExplorerGroup label items =
    column (Explorer Group)
        [ spacing <| spacingScale 2 ]
        [ el NoStyle [] <| text label
        , viewExplorerFolder items
        ]


viewExplorerFolder items =
    column (Explorer Folder) [] <| List.map viewExplorerFile items


viewExplorerFile label =
    el (Explorer File) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text label



-- VIEW WORKSPACE


viewWorkspace =
    column NoStyle
        [ width fill ]
        [ viewTabBar
        , viewEditor
        ]


viewTabBar =
    row (Workspace TabBar)
        []
        [ viewTab True "Chapter One"
        , viewTab False "Chapter Three"
        , viewTab False "Mr Bennet"
        ]


viewTab active label =
    el
        (Workspace <| Tab active)
        [ paddingTop <| paddingScale 2
        , paddingBottom <| paddingScale 2
        , paddingLeft <| paddingScale 3
        , paddingRight <| paddingScale 3
        ]
    <|
        text label


viewEditor =
    column NoStyle
        [ width fill
        , height fill
        , paddingLeft <| paddingScale 6
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
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 2 ]
        [ el (Meta MetaHeading) [] <| text "Synopsis"
        , paragraph NoStyle [] <|
            [ text <|
                "Mr & Mrs Bennet have a conversation. Sociis natoque penatibus et "
                    ++ "magnis dis parturient montes, nascetur ridiculus mus. Maecenas "
                    ++ "faucibus mollis interdum."
            ]
        ]



-- STYLE


type Styles
    = NoStyle
    | ActivityBar
    | Explorer ExplorerStyle
    | Meta MetaStyle
    | Workspace WorkspaceStyle


type ExplorerStyle
    = ExplorerWrapper
    | Group
    | Folder
    | File


type MetaStyle
    = MetaWrapper
    | MetaHeading


type WorkspaceStyle
    = TabBar
    | Tab Bool


styleSheet =
    Style.styleSheet
        [ style ActivityBar <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Explorer ExplorerWrapper) <|
            panelStyles
                ++ [ Border.right 1 ]
        , style (Explorer Group)
            [ Font.size <| fontScale 2 ]
        , style (Explorer Folder)
            [ Font.size <| fontScale 1 ]
        , style (Explorer File)
            []
        , style (Meta MetaWrapper) <|
            panelStyles
                ++ [ Border.left 1 ]
        , style (Meta MetaHeading)
            [ Font.size <| fontScale 2 ]
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
            ]
        , style (Workspace (Tab True))
            [ Font.typeface (fontStack SansSerif)
            , Font.size <| fontScale 1
            , Border.right 1
            , Color.text (rgb 203 71 25)
            , Color.border (rgb 229 229 229)
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



-- type UiColor
-- =


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
