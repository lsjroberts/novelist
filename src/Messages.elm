module Messages exposing (..)

import Time exposing (Time)
import Data.Ui exposing (ViewType, Selection)


type Msg
    = GoToSettings String
    | NewTime Time
    | OpenProject String
    | Select Selection
    | SetActiveFile Int
    | SetActiveView ViewType
    | SetSceneName Int String
    | SetSceneWordTarget Int String
    | SetAuthor String
    | SetDeadline String
    | SetTargetWordCount String
    | SetTitle String
    | ToggleFileExpanded Int
    | Write Int String
