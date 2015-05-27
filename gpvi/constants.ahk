TYPE_SIZES := { "UChar": 1, "Char": 1
              , "UShort": 2, "Short": 2
              , "UInt": 4, "Int": 4
              , "UFloat": 4, "Float": 4
              , "Int64": 8, "Double": 8 }

; Guitar Pro 5 window title.
WIN_TITLE := "Guitar Pro 5 ahk_class TMainForm"
SAVE_AS_WIN_TITLE := "Save As ahk_class #32770"
CONFIRMATION_WIN_TITLE := "Confirmation ahk_class TFMyMsg"
WARNING_WIN_TITLE := "Warning ahk_class TFMyMsg"

; Wait for dialog to show up.
DIALOG_DELAY := 50
; Wait for bar to select.
BAR_SELECTION_DELAY := 50
; Wait after each main loop iteration.
LOOP_DELAY := 5
; Wait before querying cursor position.
CURSOR_DELAY := 10

; Base address of Guitar Pro version.
GP_VERSION_BASE_ADDR := { "5.1": 0x0065FF95
                        , "5.2": 0x006358F5 }
; Base address of cursor information.
CURSOR_BASE_ADDR := { "5.1": 0x0076F2A8
                    , "5.2": 0x00776E10 }
; Current bar: UInt
CURSOR_BAR_OFFSET := 0x27D4
; Beat number under cursor, bar-relative: UInt
CURSOR_X_OFFSET := 0x27D8
; Guitar string under cursor: UInt
CURSOR_Y_OFFSET := 0x27DC
; Selection mode: UChar
IS_SELECTED_OFFSET := 0x27F8
