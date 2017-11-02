module Main exposing (..)

import Color exposing (rgb, rgba)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html exposing (Html, program)
import Html.Attributes
import Maybe.Extra
import Set exposing (Set)
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
        , update = updateWithCmds
        , subscriptions = subscriptions
        }



-- MSG


type Msg
    = SetActivity Activity
    | OpenFile FileId
    | CloseFile FileId



-- MODEL


type alias Model =
    { activity : Activity
    , files : Dict FileId File
    , openFiles : Set FileId
    , activeFile : Maybe FileId
    }


type Activity
    = Manuscript
    | Characters
    | Locations
    | Search
    | Plan
    | Editor


type alias FileId =
    Int


type alias File =
    { name : String }


init : ( Model, Cmd Msg )
init =
    ( Model
        Manuscript
        (Dict.fromList
            [ ( 0, File "Chapter One" )
            , ( 1, File "Chapter Two" )
            , ( 2, File "Chapter Three" )
            , ( 3, File "Chapter Four" )
            ]
        )
        (Set.fromList [ 0, 2 ])
        (Just 0)
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    Element.viewport styleSheet <|
        row NoStyle
            [ height (percent 100) ]
            [ viewActivityBar model.activity
            , viewExplorer model.files model.activeFile
            , viewWorkspace model.files model.openFiles model.activeFile
            , viewMetaPanel
            ]



-- VIEW ACTIVITY BAR


viewActivityBar activity =
    column (Activity ActivityWrapper)
        []
        [ viewActivityItem activity Manuscript Icon.book
        , viewActivityItem activity Characters Icon.gistSecret
        , viewActivityItem activity Locations Icon.globe
        , viewActivityItem activity Search Icon.search
        , viewActivityItem activity Plan Icon.gitBranch
        , viewActivityItem activity Editor Icon.checklist
        ]


viewActivityItem activeActivity activity icon =
    largeIcon
        |> icon
        |> html
        |> el (Activity <| ActivityItem (activity == activeActivity))
            [ padding <| paddingScale 2
            , onClick (SetActivity activity)
            ]



-- VIEW EXPLORER


viewExplorer files activeFile =
    column (Explorer ExplorerWrapper)
        [ width (px 240)
          -- , spacing <| spacingScale 3
        ]
        [ viewExplorerHeader
        , viewExplorerFolder files activeFile
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


viewExplorerFolder files maybeActive =
    let
        viewFile fileId file =
            viewExplorerFile
                (case maybeActive of
                    Just active ->
                        active == fileId

                    Nothing ->
                        False
                )
                fileId
                file.name
    in
        column (Explorer ExplorerFolder) [] <|
            Dict.values (Dict.map viewFile files)


viewExplorerFile isActive fileId name =
    row (Explorer (ExplorerFile isActive))
        [ paddingXY (paddingScale 3) (paddingScale 1)
        , spacing <| paddingScale 1
        , onClick (OpenFile fileId)
        ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el NoStyle []
        , text name
        ]



-- VIEW WORKSPACE


viewWorkspace files openFiles activeFile =
    column NoStyle
        [ width fill ]
        [ viewTabBar files openFiles activeFile
        , viewEditor
        , viewStatusBar
        ]


viewTabBar files openFiles activeFile =
    let
        tab fileId =
            viewTab Icon.file
                fileId
                (Maybe.Extra.unwrap "" (\f -> f.name) (Dict.get fileId files))
                (Maybe.Extra.unwrap False (\a -> fileId == a) activeFile)
    in
        row (Workspace TabBar) [] <|
            (openFiles |> Set.toList |> List.map tab)
                ++ [ viewTab Icon.gistSecret 99 "Mr Bennet" False
                   ]


viewTab icon fileId name isActive =
    row
        (Workspace <| Tab isActive)
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
        , el NoStyle [ onClick (OpenFile fileId) ] <| text name
        , smallIcon
            |> Icon.color "grey"
            |> Icon.x
            |> html
            |> el NoStyle [ onClick (CloseFile fileId) ]
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
            , el (Meta MetaStatus) [ alignLeft, paddingXY (paddingScale 2) (paddingScale 1) ] <| text "Draft"
            , row NoStyle
                [ spacing <| spacingScale 1 ]
                [ el (Meta MetaTag) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text "tag"
                , el (Meta MetaTag) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text "another tag"
                , el (Meta MetaTag) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text "third tag"
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
                , text "Charles Bingley"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Sir William Lucas"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Lady Lucas"
                ]
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.gistSecret
                    |> html
                    |> el NoStyle []
                , text "Elizabeth Bennet"
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
    | MetaStatus
    | MetaTag


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
        , style (Meta MetaStatus)
            [ Border.rounded 100
            , Color.background (rgb 200 200 241)
            ]
        , style (Meta MetaTag)
            [ Border.rounded 100
            , Color.background (rgb 241 200 200)
            ]
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


updateWithCmds : Msg -> Model -> ( Model, Cmd Msg )
updateWithCmds msg model =
    ( update msg model, Cmd.none )


update : Msg -> Model -> Model
update msg model =
    case msg of
        CloseFile fileId ->
            { model
                | activeFile =
                    case model.activeFile of
                        Just activeFile ->
                            if activeFile == fileId then
                                Nothing
                            else
                                model.activeFile

                        Nothing ->
                            Nothing
                , openFiles = Set.remove fileId model.openFiles
            }

        OpenFile fileId ->
            { model
                | activeFile = Just fileId
                , openFiles = Set.insert fileId model.openFiles
            }

        SetActivity activity ->
            { model | activity = activity }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UTILS


byId : List ( Int, a ) -> Int -> Maybe a
byId xs id =
    xs
        |> List.filterMap
            (\( xId, x ) ->
                if xId == id then
                    Just x
                else
                    Nothing
            )
        |> List.head
