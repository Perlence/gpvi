; Guitar Pro 5 window title.
WIN_TITLE := "Guitar Pro 5 ahk_class TMainForm"

; Wait for dialog to show up.
DIALOG_DELAY := 50
; Wait for bar to select.
BAR_SELECTION_DELAY := 10
; Wait after each main loop iteration.
LOOP_DELAY := 5

; Address of current bar, UInt
ADDR_CURSOR_BAR := 0x02F3A7C8
; Address of beat number under cursor, bar-relative, UInt
ADDR_CURSOR_X := 0x02F3A7CC
; Address of guitar string under cursor, UInt
ADDR_CURSOR_Y := 0x02F3A7D0
; Address of selection mode, UChar
ADDR_IS_SELECTED := 0x02F3A7EC
