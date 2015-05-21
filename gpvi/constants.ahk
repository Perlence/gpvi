TYPE_SIZES := { "UChar": 1, "Char": 1
              , "UShort": 2, "Short": 2
              , "UInt": 4, "Int": 4
              , "UFloat": 4, "Float": 4
              , "Int64": 8, "Double": 8 }

; Guitar Pro 5 window title.
WIN_TITLE := "Guitar Pro 5 ahk_class TMainForm"

; Wait for dialog to show up.
DIALOG_DELAY := 50
; Wait for bar to select.
BAR_SELECTION_DELAY := 10
; Wait after each main loop iteration.
LOOP_DELAY := 5

; Base address
BASE_ADDR := 0x00776e10
; Current bar: UInt
CURSOR_BAR_OFFSET := 0x27D4
; Beat number under cursor, bar-relative: UInt
CURSOR_X_OFFSET := 0x27D8
; Guitar string under cursor: UInt
CURSOR_Y_OFFSET := 0x27DC
; Selection mode: UChar
IS_SELECTED_OFFSET := 0x27F8
; dynamic of note under cursor: UChar
;   ppp: 27
;   pp:  28
;   ...
;   fff: 34
ADDR_NOTE_DYNAMIC := 0x0154D980
