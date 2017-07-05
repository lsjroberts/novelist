module Views.Settings exposing (view)

import Html exposing (..)
import Html.Attributes
    exposing
        ( placeholder
        , type_
        , value
        )
import Html.Events exposing (..)
import Maybe.Extra
import Data.Model exposing (Model)
import Styles exposing (class)
import Messages exposing (Msg(..))
import Utils.Date exposing (..)
import Views.Common exposing (viewMenu)


view : Model -> Html Msg
view model =
    div [ class [ Styles.SettingsWrapper ] ]
        [ viewMenu model.activeView
        , div
            [ class [ Styles.Settings ] ]
            [ h1 [ class [ Styles.SettingsHeader ] ] [ Html.text "Settings" ]
            , viewProjectMeta model
            , viewEditorSettings model
            , viewCompileSettings model
            ]
        ]


viewProjectMeta : Model -> Html Msg
viewProjectMeta model =
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Project" ]
        , viewFormInput
            "Title"
            (Just "The title of your story, displayed on the blah blah")
            (input
                [ class [ Styles.FormInputText ]
                , onInput SetTitle
                , value model.title
                ]
                []
            )
        , viewFormInput
            "Author"
            (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
            (input
                [ class [ Styles.FormInputText ]
                , onInput SetAuthor
                , value model.author
                ]
                []
            )
        , viewFormInput
            "Total Word Target"
            (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
            (input
                [ class [ Styles.FormInputText ]
                , type_ "number"
                , placeholder "Default: 80000"
                , onInput SetTargetWordCount
                , model.totalWordTarget
                    |> Maybe.Extra.unwrap "" toString
                    |> value
                ]
                []
            )
        , viewFormInput
            ("Deadline ("
                ++ (timeUntilDeadline model.time model.deadline)
                ++ ")"
            )
            (Just
                ("Cras mattis consectetur purus sit amet fermentum.")
            )
            (input
                [ class [ Styles.FormInputText ]
                , type_ "date"
                , onInput SetDeadline
                , model.deadline
                    |> Maybe.Extra.unwrap "" formatDateShort
                    |> value
                ]
                []
            )
        ]


viewEditorSettings : Model -> Html Msg
viewEditorSettings model =
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Editor" ]
        , viewFormInput
            "Theme"
            (Just "Sed posuere consectetur est at lobortis.")
            (input
                [ class [ Styles.FormInputText ]
                , placeholder "Default: Solarized Light"
                ]
                []
            )
        , viewFormInput
            "Font Size"
            (Just "The base font size for the editor, this does not affect the font size in your compiled book")
            (input
                [ class [ Styles.FormInputText ]
                , type_ "number"
                , placeholder "Default: 16"
                ]
                []
            )
        ]


viewCompileSettings : Model -> Html Msg
viewCompileSettings model =
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Compile" ]
        , viewFormInputOption
            ".pdf"
            (Just "Create a .pdf when you click the 'compile' button")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxChecked
                    ]
                ]
                [ Html.text "Y" ]
            )
        , viewFormInputOption
            ".epub"
            (Just "Coming soon!")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxDisabled
                    ]
                ]
                []
            )
        , viewFormInputOption
            ".mobi"
            (Just "Coming soon!")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxDisabled
                    ]
                ]
                []
            )
        ]


viewFormInput : String -> Maybe String -> Html Msg -> Html Msg
viewFormInput label maybeDesc formInput =
    div [ class [ Styles.FormInput ] ]
        [ div [ class [ Styles.FormInputLabel ] ] [ Html.text label ]
        , case maybeDesc of
            Just desc ->
                div [ class [ Styles.FormInputDescription ] ] [ Html.text desc ]

            Nothing ->
                span [] []
        , formInput
        ]


viewFormInputOption : String -> Maybe String -> Html Msg -> Html Msg
viewFormInputOption label maybeDesc formInput =
    div [ class [ Styles.FormInputOption ] ]
        [ div [ class [ Styles.FormInputOptionInput ] ] [ formInput ]
        , div [ class [ Styles.FormInputLabel ] ] [ Html.text label ]
        , case maybeDesc of
            Just desc ->
                div [ class [ Styles.FormInputDescription ] ] [ Html.text desc ]

            Nothing ->
                span [] []
        ]
