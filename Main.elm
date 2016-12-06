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
            { model | isWriting = False }

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
            { model
                | sceneContent = Debug.log "write" <| String.join "\n" sceneContent
                , isWriting = False
            }



-- VIEW


view : Model -> Html Message
view model =
    div [ styles [ padding (px 30) ], textStyle ]
        [ leftSideBarView model
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
                  -- , onBlur StopWriting
                  -- , onBlur <| Debug.log "hello" <| (Write [ "boo" ])
                  -- , on "blur" <| Debug.log "hello" <| (Decode.map Write <| Decode.at [ "target", "firstChild" ] textContentDecoder)
                , on "blur" (Decode.map Write childrenContentDecoder)
                ]
                (sceneAsTokensView model)
            ]
        , rightSideBarView model
        ]


leftSideBarView model =
    section
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


rightSideBarView model =
    section
        [ menuStyle
        , rightMenuStyle
        , if model.isWriting then
            menuIsWritingStyle
          else
            noStyle
        ]
        [ Html.text "info" ]


sceneAsTokensView : Model -> List (Html a)
sceneAsTokensView model =
    case model.isWriting of
        True ->
            model.sceneContent
                |> tokenise
                |> splitSceneTokensIntoParagraphs
                |> (mapSceneParagraphsIntoElements noopFormatter)

        False ->
            model.sceneContent
                |> tokenise
                |> splitSceneTokensIntoParagraphs
                |> (mapSceneParagraphsIntoElements punctuatorFormatter)


debugTokens : List Token -> List (Html a)
debugTokens tokens =
    tokens
        |> map (\t -> p [] [ Html.text (t.tokenType ++ " (" ++ t.kind ++ "): " ++ t.value) ])


splitSceneTokensIntoParagraphs : List Token -> List (List Token)
splitSceneTokensIntoParagraphs tokens =
    tokens
        |> splitWith (\t -> t.tokenType == "NewLine")


mapSceneParagraphsIntoElements : TokenFormatter a -> List (List Token) -> List (Html a)
mapSceneParagraphsIntoElements tokenFormatter paragraphs =
    paragraphs
        |> map (mapSceneTokensIntoElements tokenFormatter)
        |> map (\paragraph -> p [ sceneParagraphStyle ] paragraph)


mapSceneTokensIntoElements : TokenFormatter a -> List Token -> List (Html a)
mapSceneTokensIntoElements tokenFormatter tokens =
    tokens
        |> map (tokenIntoElement tokenFormatter)


type alias TokenFormatter msg =
    Token -> Html.Attribute msg


tokenIntoElement : TokenFormatter a -> Token -> Html a
tokenIntoElement tokenFormatter token =
    let
        tokenStyle =
            tokenFormatter token
    in
        span [ tokenStyle ] [ Html.text token.value ]


noopFormatter : Token -> Html.Attribute a
noopFormatter token =
    styles []


punctuatorFormatter : Token -> Html.Attribute a
punctuatorFormatter token =
    case token.tokenType of
        "Punctuator" ->
            tokenPunctuatorStyle

        _ ->
            styles []


childrenContentDecoder : Decode.Decoder (List String)
childrenContentDecoder =
    Decode.at [ "target", "childNodes" ] (Decode.keyValuePairs textContentDecoder)
        |> Decode.map
            (\nodes ->
                nodes
                    |> List.filterMap
                        (\( key, text ) ->
                            case String.toInt key of
                                Err msg ->
                                    Nothing

                                Ok value ->
                                    Just text
                        )
                    |> List.reverse
            )


textContentDecoder : Decode.Decoder String
textContentDecoder =
    Decode.oneOf [ Decode.field "textContent" Decode.string, Decode.succeed "nope" ]


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
