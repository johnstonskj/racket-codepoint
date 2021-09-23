#lang racket/base

(provide 
  *case-folding-status*
  *general-categories*
  *name-alias-types*)

(define *case-folding-status*
  '((common . "common case folding, common mappings shared by both simple and full mappings")
    (simple . "simple case folding, mappings to single characters where different from full")
    (full . "full case folding, mappings that cause strings to grow in length. Multiple characters are separated by spaces")
    (turkic . "special case for uppercase I and dotted uppercase I")))

(define *name-alias-types*
  '((abbreviation . "Commonly occurring abbreviations (or acronyms) for control codes, format characters, spaces, and variation selectors") 
    (alternate . "A few widely used alternate names for format characters") 
    (control . "ISO 6429 names for C0 and C1 control functions, and other commonly occurring names for control codes") 
    (correction . "Corrections for serious problems in the character names") 
    (figment . "Several documented labels for C1 control code points which were never actually approved in any standard")))

(define *general-categories*
  '((Lu . "Uppercase letter")
    (Pf . "Final quote punctuation")
    (Ll . "Lowercase letter")
    (Po . "Other punctuation")
    (Lt . "Titlecase letter")
    (Sm . "Math symbol")
    (Lm . "Modifier letter")
    (Sc . "Currency symbol")
    (Lo . "Other letter")
    (Sk . "Modifier symbol")
    (Mn . "Non-spacing mark")
    (So . "Other symbol")
    (Mc . "Combining spacing mark")
    (Zs . "Space separator")
    (Me . "Enclosing mark")
    (Zl . "Line separator")
    (Nd . "Decimal digit number")
    (Zp . "Paragraph separator")
    (Nl . "Letter number")
    (Cc . "Control")
    (No . "Other number")
    (Cf . "Format")
    (Pc . "Connector punctuation")
    (Cs . "Surrogate")
    (Pd . "Dash punctuation")
    (Co . "Private use")
    (Ps . "Open punctuation")
    (Cn . "Unassigned")
    (Pe . "Close punctuation")
    (Pi . "Initial quote punctuation")))