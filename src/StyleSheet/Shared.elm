module StyleSheet.Shared exposing (..)

import Style exposing (..)


fonts =
    { body =
        { normal =
            Style.mix
                [ font "'Quicksand', 'sans-serif'"
                , fontsize 16
                , lineHeight 1.4
                ]
        }
    , novel =
        Style.mix
            [ font "'Cochin', 'Georgia', 'serif'"
            , fontsize 16
            , lineHeight 1.6
            ]
    }
