module Main exposing (..)

import Css exposing (..)
import List exposing (map)
import Html exposing (Html, div, span, section, article, header, h1, p, ul, li)
import Html.Attributes exposing (style, contenteditable, spellcheck)
import Html exposing (beginnerProgram)
import Html.Events exposing (onClick, onInput, onBlur, onFocus, on)
import Json.Decode as Decode
import Defaults exposing (..)
import Analysis exposing (..)
import List.Split exposing (splitWith)


main : Program Never Model Message
main =
    beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { sceneTitle : String
    , sceneContent : String
    , isWriting : Bool
    }


model : Model
model =
    { sceneTitle = defaultSceneTitle
    , sceneContent = defaultSceneContent
    , isWriting = False
    }



-- UPDATE


type Message
    = StartWriting
    | StopWriting
    | Write (List String)


update : Message -> Model -> Model
update message model =
    case message of
        StartWriting ->
            { model | isWriting = True }

        StopWriting ->
            Debug.log "StopWriting" model

        -- { model | isWriting = False }
        Write sceneContent ->
            -- { model | sceneContent = (Debug.crash "SHIT" sceneContent) }
            -- let
            --     first =
            --         Debug.log "first" <| List.head sceneContent
            -- in
            --     case first of
            --         Just f ->
            --             { model | sceneContent = f }
            --
            --         Nothing ->
            --             { model | sceneContent = "nope" }
            -- { model | sceneContent = Debug.log "write" <| sceneContent }
            { model | sceneContent = Debug.log "write" <| String.join "\n" sceneContent }



-- VIEW


view : Model -> Html Message
view model =
    div [ styles [ padding (px 30) ], textStyle ]
        [ section
            [ menuStyle
            , leftMenuStyle
            , if model.isWriting then
                menuIsWritingStyle
              else
                noStyle
            ]
            [ div
                [ menuGroupStyle ]
                [ span [ menuGroupTitleStyle ] [ Html.text "Modes" ]
                , ul [ menuGroupOptionsStyle ]
                    [ li [ menuGroupItemStyle, menuGroupItemSelectedStyle ] [ Html.text "Distraction Free" ]
                    , li [ menuGroupItemStyle ] [ Html.text "Conversation" ]
                    , li [ menuGroupItemStyle ] [ Html.text "Editor" ]
                    ]
                ]
            ]
        , section [ sceneStyle ]
            [ header []
                [ h1 [ sceneTitleStyle ] [ Html.text model.sceneTitle ]
                ]
            , article
                [ sceneContentStyle
                , if model.isWriting then
                    sceneContentIsWritingStyle
                  else
                    noStyle
                , contenteditable True
                , spellcheck False
                , onFocus StartWriting
                , onBlur StopWriting
                  -- , onBlur <| Debug.log "hello" <| (Write [ "boo" ])
                  -- , on "blur" <| Debug.log "hello" <| (Decode.map Write <| Decode.at [ "target", "firstChild" ] textContentDecoder)
                , on "blur" <| Debug.log "hello" <| (Decode.map Write <| childrenContentDecoder)
                ]
                (sceneAsTokensView model.sceneContent)
            ]
        , section
            [ menuStyle
            , rightMenuStyle
            , if model.isWriting then
                menuIsWritingStyle
              else
                noStyle
            ]
            [ Html.text "info" ]
        ]


sceneAsTokensView : String -> List (Html a)
sceneAsTokensView scene =
    -- |> debugTokens
    scene
        |> tokenise
        |> splitSceneTokensIntoParagraphs
        |> mapSceneParagraphsIntoElements


debugTokens : List Token -> List (Html a)
debugTokens tokens =
    tokens
        |> map (\t -> p [] [ Html.text (t.tokenType ++ " (" ++ t.kind ++ "): " ++ t.value) ])


splitSceneTokensIntoParagraphs : List Token -> List (List Token)
splitSceneTokensIntoParagraphs tokens =
    tokens
        |> splitWith (\t -> t.tokenType == "NewLine")


mapSceneParagraphsIntoElements : List (List Token) -> List (Html a)
mapSceneParagraphsIntoElements paragraphs =
    paragraphs
        |> map mapSceneTokensIntoElements
        |> map (\paragraph -> p [ sceneParagraphStyle ] paragraph)


mapSceneTokensIntoElements : List Token -> List (Html a)
mapSceneTokensIntoElements tokens =
    tokens
        |> map tokenIntoElement


tokenIntoElement : Token -> Html a
tokenIntoElement token =
    let
        tokenStyle =
            case token.tokenType of
                "Punctuator" ->
                    tokenPunctuatorStyle

                _ ->
                    styles []
    in
        span [ tokenStyle ] [ Html.text token.value ]


childrenContentDecoder : Decode.Decoder (List String)
childrenContentDecoder =
    Decode.at [ "target", "childNodes" ] (Decode.list textContentDecoder)


textContentDecoder : Decode.Decoder String
textContentDecoder =
    Decode.field "textContent" Decode.string


styles : List Mixin -> Html.Attribute msg
styles =
    Css.asPairs >> style


noStyle =
    styles []


spacing =
    px 30


textStyle =
    styles
        [ fontFamilies [ "Avenir Next" ]
        , color (hex "333333")
        ]


menuStyle =
    styles
        [ position fixed
        , top spacing
        , width (pct 20)
        ]


leftMenuStyle =
    styles
        [ left spacing
        ]


rightMenuStyle =
    styles
        [ right spacing
        ]


menuIsWritingStyle =
    styles
        [ opacity (num 0.3)
        ]


menuGroupStyle =
    styles
        [ marginBottom spacing
        ]


menuGroupTitleStyle =
    styles
        [ fontSize (px 18)
        ]


menuGroupOptionsStyle =
    styles
        [ listStyle none
        , cursor pointer
        , margin zero
        , padding zero
        ]


menuGroupItemStyle =
    styles
        [ paddingLeft (em 1)
        ]


menuGroupItemSelectedStyle =
    styles
        [ fontWeight (int 600)
        ]


sceneStyle =
    styles
        [ marginLeft (pct 23)
        , width (pct 54)
        ]


sceneTitleStyle =
    styles
        [ fontFamilies [ "Cochin" ]
        , fontSize (px 48)
        , fontWeight (int 300)
        , textAlign center
        , color (hex "333333")
        ]


sceneContentStyle =
    styles
        [ outline zero
        , fontFamilies [ "Cochin" ]
        , fontSize (px 24)
        , lineHeight (px 31.2)
        , color (hex "333333")
        ]


sceneContentIsWritingStyle =
    styles
        []


sceneParagraphStyle =
    styles
        [ margin (px 0)
        , textIndent (em 1)
        ]


tokenPunctuatorStyle =
    styles
        [ backgroundColor (rgba 0 189 156 0.2)
        ]
