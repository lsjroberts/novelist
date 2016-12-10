module Mocks.Austen exposing (..)

import Token.Types exposing (..)


prideAndPrejudice =
    markdownToTokens
        ("It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife."
            ++ "\nHowever little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered the rightful property of some one or other of their daughters."
            ++ "\n“My dear Mr. Bennet,” said his lady to him one day, “have you heard that Netherfield Park is let at last?”"
            ++ "\nMr. Bennet replied that he had not."
            ++ "\n“But it is,” returned she; “for Mrs. Long has just been here, and she told me all about it.”"
            ++ "\nMr. Bennet made no answer."
            ++ "\n“Do you not want to know who has taken it?” cried his wife impatiently."
            ++ "\n“_You_ want to tell me, and I have no objection to hearing it.”"
            ++ "\nThis was invitation enough."
        )
