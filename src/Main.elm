module Main exposing (..)

import Color exposing (rgb, rgba)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
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
import Style.Transition as Transition
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
    = NoOp
    | SetActivity Activity
    | OpenFile FileId
    | CloseFile FileId
    | SetWordTarget String



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
    { name : String
    , fileType : FileType
    }


type FileType
    = SceneFile Scene
    | CharacterFile Character
    | LocationFile


type alias Scene =
    { synopsis : String
    , status : String
    , tags : List String
    , characters : Dict FileId SceneCharacter
    , locations : List FileId
    , wordTarget : Maybe Int
    }


type alias SceneCharacter =
    { speaking : Bool }


type alias Character =
    { aliases : List String }


init : ( Model, Cmd Msg )
init =
    ( Model
        Manuscript
        (Dict.fromList
            [ ( 0
              , File "Chapter One"
                    (SceneFile <|
                        Scene "Mr and Mrs Bennet have a conversation. Maecenas sed diam eget risus varius blandit sit amet non magna. Sed posuere consectetur est at lobortis."
                            "Draft"
                            [ "tag", "another tag", "one more", "further tags yay" ]
                            (Dict.fromList
                                [ ( 4, SceneCharacter True )
                                , ( 5, SceneCharacter True )
                                , ( 6, SceneCharacter False )
                                ]
                            )
                            []
                            Nothing
                    )
              )
            , ( 1, File "Chapter Two" (SceneFile <| Scene "A dance" "Draft" [] (Dict.fromList []) [] <| Just 2000) )
            , ( 2, File "Chapter Three" (SceneFile <| Scene "" "Draft" [] (Dict.fromList []) [] Nothing) )
            , ( 3, File "Chapter Four" (SceneFile <| Scene "" "Draft" [] (Dict.fromList []) [] Nothing) )
            , ( 4, File "Mr. Bennet" (CharacterFile <| Character [ "Mr. Bennet, Esquire" ]) )
            , ( 5, File "Mrs. Bennet" (CharacterFile <| Character []) )
            , ( 6, File "Charles Bingley" (CharacterFile <| Character [ "Mr. Bingley", "Bingley" ]) )
            ]
        )
        (Set.fromList [ 0, 2 ])
        (Just 0)
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    let
        activeFile =
            case model.activeFile of
                Just fileId ->
                    Dict.get fileId model.files

                Nothing ->
                    Nothing

        wordTarget =
            case activeFile of
                Just file ->
                    case file.fileType of
                        SceneFile scene ->
                            scene.wordTarget

                        _ ->
                            Nothing

                Nothing ->
                    Nothing
    in
        Element.viewport styleSheet <|
            row NoStyle
                [ height (percent 100) ]
                [ viewActivityBar model.activity
                , viewExplorer model.activity model.files model.activeFile
                , viewWorkspace model.files model.openFiles model.activeFile wordTarget
                , viewMetaPanel model.files activeFile
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
        |> el (Activity ActivityItem)
            [ padding <| paddingScale 2
            , onClick (SetActivity activity)
            , vary Active (activity == activeActivity)
            ]



-- VIEW EXPLORER


viewExplorer activity files activeFile =
    column (Explorer ExplorerWrapper)
        [ width (px 240)
          -- , spacing <| spacingScale 3
        ]
        [ viewExplorerHeader
        , viewExplorerFolder activity files activeFile
        , row (Explorer ExplorerFile)
            [ paddingXY (paddingScale 3) (paddingScale 1)
            , spacing <| paddingScale 1
            , vary Active False
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
        [ paddingXY (paddingScale 3) (paddingScale 2)
        , spacing <| spacingScale 1
        ]
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


viewExplorerFolder activity files maybeActive =
    let
        filterByActivity fileId file =
            case file.fileType of
                SceneFile _ ->
                    activity == Manuscript

                CharacterFile _ ->
                    activity == Characters

                _ ->
                    False

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
            Dict.values (Dict.map viewFile (Dict.filter filterByActivity files))


viewExplorerFile isActive fileId name =
    row (Explorer ExplorerFile)
        [ paddingXY (paddingScale 3) (paddingScale 1)
        , spacing <| paddingScale 1
        , onClick (OpenFile fileId)
        , vary Active isActive
        ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el NoStyle []
        , text name
        ]



-- VIEW WORKSPACE


viewWorkspace files openFiles activeFile wordTarget =
    column NoStyle
        [ width fill ]
        [ viewTabBar files openFiles activeFile
        , viewEditor files activeFile
        , viewStatusBar wordTarget
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


viewTab icon fileId name isActive =
    row
        (Workspace Tab)
        [ paddingTop <| paddingScale 2
        , paddingBottom <| paddingScale 2
        , paddingLeft <| paddingScale 3
        , paddingRight <| paddingScale 3
        , spacing <| paddingScale 1
        , vary Active isActive
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


viewEditor : Dict FileId File -> Maybe FileId -> Element Styles Variations Msg
viewEditor files activeFile =
    let
        maybeFile =
            Maybe.Extra.unwrap Nothing (\fileId -> Dict.get fileId files) activeFile

        viewFile =
            case maybeFile of
                Just file ->
                    case file.fileType of
                        SceneFile scene ->
                            --viewMonacoEditor activeFile
                            el Placeholder [ width fill, height fill ] empty

                        CharacterFile character ->
                            viewCharacterEditor file character

                        _ ->
                            el Placeholder [ width fill, height fill ] empty

                Nothing ->
                    el Placeholder [ width fill, height fill ] empty
    in
        column NoStyle
            [ width fill
            , height fill
            , paddingTop <| paddingScale 4
            , paddingRight <| paddingScale 6
            , paddingBottom <| paddingScale 4
            , paddingLeft <| paddingScale 6
            ]
            [ viewFile ]


viewMonacoEditor activeFile =
    case activeFile of
        Just fileId ->
            html <|
                Html.iframe
                    [ Html.Attributes.src ("http://localhost:8080/editor/editor.html?file=/stubs/PrideAndPrejudice.novel/manuscript/" ++ (toString fileId) ++ ".txt")
                    , Html.Attributes.style
                        [ ( "width", "100%" )
                        , ( "height", "100%" )
                        , ( "border", "none" )
                        ]
                    ]
                    []

        Nothing ->
            el NoStyle [] empty


viewCharacterEditor : File -> Character -> Element Styles Variations Msg
viewCharacterEditor file character =
    column (Workspace CharacterEditor)
        [ width fill, height fill, spacing <| spacingScale 3 ]
        [ h1 (Workspace CharacterEditorTitle) [] <|
            Input.text InputText
                [ paddingXY 0 (paddingScale 2)
                , vary Light True
                ]
                { onChange = SetWordTarget
                , value = file.name
                , label = Input.hiddenLabel "Name"
                , options = []
                }
        , if List.length character.aliases > 0 then
            column NoStyle
                [ spacing <| spacingScale 1 ]
                [ el NoStyle [] <| text "Also known as:"
                , column NoStyle [] <|
                    List.map
                        (\a ->
                            Input.text InputText
                                [ paddingXY 0 (paddingScale 2)
                                , vary Light True
                                ]
                                { onChange = SetWordTarget
                                , value = a
                                , label = Input.hiddenLabel "Alias"
                                , options = []
                                }
                        )
                        character.aliases
                ]
          else
            el NoStyle [] empty
        ]



-- VIEW META PANEL


viewMetaPanel files activeFile =
    case activeFile of
        Just file ->
            case file.fileType of
                CharacterFile character ->
                    viewCharacterMeta file character

                SceneFile scene ->
                    viewSceneMeta files scene

                _ ->
                    el NoStyle [] empty

        Nothing ->
            el NoStyle [] empty


viewCharacterMeta file character =
    column (Meta MetaWrapper)
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 4 ]
        [ column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text file.name ]
        ]


viewSceneMeta files scene =
    column (Meta MetaWrapper)
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 4 ]
        [ column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Synopsis"
            , Input.multiline InputText
                [ paddingXY (paddingScale 2) (paddingScale 2)
                , minHeight (px (fontScale 9))
                ]
                { onChange = (\s -> NoOp)
                , value = scene.synopsis
                , label = Input.hiddenLabel "Synopsis"
                , options = []
                }
            , el (Meta MetaStatus)
                [ alignLeft
                , paddingXY (paddingScale 2) (paddingScale 1)
                ]
              <|
                text scene.status
            , row NoStyle
                [ spacing <| spacingScale 1 ]
              <|
                List.map (\tag -> el (Meta MetaTag) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text tag) scene.tags
            ]
        , viewSceneCharacters files scene.characters
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
        , column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Word Target"
            , Input.text InputText
                [ paddingXY (paddingScale 2) (paddingScale 2) ]
                { onChange = SetWordTarget
                , value = Maybe.Extra.unwrap "" toString scene.wordTarget
                , label = Input.hiddenLabel "Word Target"
                , options = []
                }
            ]
        ]


viewSceneCharacters files characters =
    let
        viewCharacter characterId sceneCharacter =
            let
                maybeCharacterFile =
                    Dict.get characterId files
            in
                case maybeCharacterFile of
                    Just characterFile ->
                        row NoStyle
                            [ spacing <| paddingScale 1 ]
                            [ smallIcon
                                |> Icon.gistSecret
                                |> html
                                |> el NoStyle []
                            , text characterFile.name
                            , if sceneCharacter.speaking then
                                smallIcon
                                    |> Icon.megaphone
                                    |> html
                                    |> el NoStyle []
                              else
                                el NoStyle [] empty
                            ]

                    Nothing ->
                        el NoStyle [] empty
    in
        column NoStyle
            [ spacing <| spacingScale 1 ]
            ([ el (Meta MetaHeading) [] <| text "Characters" ]
                ++ (Dict.values <|
                        Dict.map
                            viewCharacter
                            characters
                   )
            )



-- STATUS BAR


viewStatusBar maybeWordTarget =
    row (StatusBar StatusBarWrapper)
        [ alignRight
        , spacing <| spacingScale 1
        , paddingXY (paddingScale 2) (paddingScale 1)
        ]
        [ case maybeWordTarget of
            Just wordTarget ->
                el NoStyle [] <| text ("500 / " ++ (toString wordTarget) ++ " words")

            Nothing ->
                el NoStyle [] <| text "500 words"
        , el NoStyle [] <| text "2500 characters"
        , case maybeWordTarget of
            Just wordTarget ->
                el NoStyle [] <| text ((toString (100 * 500 / (toFloat wordTarget))) ++ "%")

            Nothing ->
                el NoStyle [] empty
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



-- UPDATE


updateWithCmds : Msg -> Model -> ( Model, Cmd Msg )
updateWithCmds msg model =
    ( update msg model, Cmd.none )


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

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

        SetWordTarget targetString ->
            let
                wordTarget =
                    targetString
                        |> String.toInt
                        |> Result.toMaybe

                updateFile maybeFile =
                    case maybeFile of
                        Just file ->
                            case file.fileType of
                                SceneFile scene ->
                                    Just
                                        { file
                                            | fileType =
                                                SceneFile
                                                    { scene
                                                        | wordTarget = wordTarget
                                                    }
                                        }

                                _ ->
                                    Just file

                        Nothing ->
                            Nothing
            in
                case model.activeFile of
                    Just activeFile ->
                        { model
                            | files = Dict.update activeFile updateFile model.files
                        }

                    Nothing ->
                        model



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
