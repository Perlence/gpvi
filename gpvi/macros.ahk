/**
 * Move cursor to given direction number of times limiting movement to current
 * bar if necessary.
 *
 * @param {Str} direction - a key to send, e.g. "left" or "up".
 * @param {UInt} times - movement distance.
 * @param {Bool} limitToBar - limit movement to current bar.
 */
moveCursor(direction, times:=1, limitToBar:=false)
{
    global mode

    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {ctrl down}{shift down}

    moved := 0
    if (not limitToBar or direction = "up" or direction = "down")
    {
        send, {%direction% %times%}
        moved := times
    }
    else
    {
        cursorCur := getCursorPosition()[1]
        if (direction = "left" and cursorCur > 1)
        {
            times := min(cursorCur, times)
            send, {left %times%}
            moved := times
        }
        else if (direction = "right")
        {
            loop, %times%
            {
                send, {right}
                cursorPrev := cursorCur
                cursorCur := getCursorPosition()[1]
                if (cursorCur != cursorPrev + 1)
                {
                    send, {left}
                    break
                }
                moved += 1
            }
        }
    }

    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {ctrl up}{shift up}

    return moved
}

goToEnd(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginning(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginningOfNextBar(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginningOfPrevBar(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {home}{left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeatOfBar(number:=1)
{
    cursor := getCursorPosition()[1]
    if (number = cursor)
        return
    if (number = 1)
    {
        send, {home}
        return
    }
    distance := number - cursor
    direction := getDirection(distance)
    moveCursor(direction, abs(distance), true)
}

goToAbsoluteBeat(number:=1)
{
    goToBeginningOfScore()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToBeginningOfScore()
{
    send, {ctrl down}{home}{ctrl up}
}

goToEndOfScore()
{
    send, {ctrl down}{end}{ctrl up}{home}
}

goToBar(number:=1)
{
    if (number = 1)
    {
        goToBeginningOfScore()
        return
    }
    currentBar := getCurrentBar()
    if (number = currentBar)
        return
    distance := number - currentBar
    if (abs(distance) < number - 1)
    {
        if (distance > 0)
            goToBeginningOfNextBar(abs(distance))
        else
            goToBeginningOfPrevBar(abs(distance))
    }
    else
    {
        goToBeginningOfScore()
        goToBeginningOfNextBar(number - 1)
    }
}

goToNextMarker(number:=1)
{
    send, {ctrl down}{tab %number%}{ctrl up}
}

goToPreviousMarker(number:=1)
{
    send, {shift down}{tab %number%}{shift up}
}

alternateWindow()
{
    global WIN_TITLE
    curId := WinActive(WIN_TITLE)
    winGet, id, list, %WIN_TITLE%
    if id > 1
    {
        winShow, ahk_id %id2%
        winActivate, ahk_id %id2%
    }
}

insertMarker()
{
    send, {shift down}{insert}{shift up}
}

listMarkers()
{
    ; send, {alt}ml
    send, {alt}{right 6}{down 2}{enter}
}

/**
 * Select given number of beats limited to current bar.
 *
 * @param {Int} numberOfBeats - number of beats to select. If number is
 *   positive then select beats to the right, else select beats to the
 *   left.
 * @return {Int} number of selected beats.
 */
selectBeats(numberOfBeats:=1)
{
    direction := getDirection(numberOfBeats)
    if (numberOfBeats < 0)
    {
        if (not moveCursor("left", 1, true))
            return 0
    }
    send, {shift down}{up}{down}
    moved := moveCursor(direction, abs(numberOfBeats) - 1, true) + 1
    send, {shift up}
    return moved
}

selectBars(numberOfBars:=1)
{
    global BAR_SELECTION_DELAY
    direction := getDirection(numberOfBars)
    times := abs(numberOfBars)
    send, {ctrl down}{shift down}
    loop, %times%
    {
        send, {%direction%}
        sleep, %BAR_SELECTION_DELAY%
    }
    send, {ctrl up}{shift up}
}

selectBeatsToEnd(times:=1)
{
    send, {shift down}{up}{down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times:=1)
{
    send, {left}{shift down}{up}{down}
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times:=1)
{
    send, {shift down}{up}{down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

selectToMouse()
{
    send {shift down}{lbutton}{shift up}
}

delete(bars:=1, cut:=true)
{
    global DIALOG_DELAY
    if (not cut)
        send, {delete}
    else
    {
        send, {ctrl down}x{ctrl up}
        winWaitActive, Cut, , % DIALOG_DELAY / 1000
        if errorLevel
            deselect()
        else
        {
            if (bars > 1)
            {
                bars -= 1
                send, {tab}{up %bars%}{enter}
            }
            send, {enter}
        }
    }
}

deleteNotes(numberOfNotes:=1)
{
    loop, % abs(numberOfNotes)
    {
        if (numberOfNotes > 0)
        {
            send, {delete}{right}
        }
        else
        {
            send, {left}{delete}
        }
    }
}

/**
 * Delete beats in current bar.
 */
deleteBeats(times:=1)
{
    global mode
    if (mode = "NORMAL")
        selectBeats(times)
    delete()
}

deleteBeatsToEnd(times:=1)
{
    selectBeatsToEnd(times)
    delete(1, times = 1)
    times -= 1
    send, {left %times%}
}

deleteBeatsToBeginning(times:=1)
{
    selectBeatsToBeginning(times)
    delete(1, times = 1)
    times -= 1
    send, {left %times%}
}

deleteBars(numberOfBars:=1)
{
    delete(numberOfBars)
}

clearBars(numberOfBars:=1)
{
    if (numberOfBars = 1)
    {
        send, {home}
        selectBeatsToEnd()
        delete()
    }
    else
    {
        yank(numberOfBars)
        selectBars(numberOfBars)
        send, {delete}
        times := numberOfBars - 1
        send, {left %times%}
    }
}

/**
 * Replace beats to the right with a rest.
 *
 * @param {UInt} numberOfBeats - number of beats to change.
 * @return {UInt} how much beats have been changed.
 */
changeBeats(numberOfBeats:=1)
{
    if (numberOfBeats = 1)
    {
        replaceWithRest()
    }
    else
    {
        moved := moveCursor("right", (numberOfBeats - 1), true)
        if (not moved)
            return 0
        appendBeat()
        deleteBeats(-min(numberOfBeats, moved + 1))
        return moved
    }
}

yank(bars:=1)
{
    global DIALOG_DELAY
    send, {ctrl down}c{ctrl up}
    winWaitActive, Copy, , % DIALOG_DELAY / 1000
    if errorLevel
    {
        deselect()
    }
    else
    {
        if (bars > 1)
        {
            bars -= 1
            send, {tab}{up %bars%}{enter}
        }
        send, {enter}
    }
}

/**
 * Yank beats in current bar.
 */
yankBeats(times:=1)
{
    if (selectBeats(times))
        yank()
}

yankBeatsToBeginning(times:=1)
{
    selectBeatsToBeginning(times)
    yank()
}

yankBeatsToBeginningOfNextBar(times:=1)
{
    selectBeatsToBeginningOfNextBar(times)
    yank()
}

yankBeatsToEnd(times:=1)
{
    selectBeatsToEnd(times)
    yank()
}

yankBars(times:=1)
{
    yank(times)
}

put(putMode:="overwrite", times:=1)
{
    global DIALOG_DELAY
    send, {ctrl down}v{ctrl up}
    winWaitActive, Paste, , % DIALOG_DELAY / 1000
    if (errorLevel)
    {
        loop, % times - 1
        {
            appendBeat()
            send, {ctrl down}v{ctrl up}
            ; Delete rest to the right.
            send, {right}{delete}{left}
        }
    }
    else
    {
        send, {tab 2}

        if (putMode = "insert")
            send, {down}
        else if (putMode = "append")
            send, {down 2}

        if (times > 1)
        {
            times -= 1
            send, {tab}{up %times%}
        }
        send, {enter}
    }
}

putLeft(putMode:="overwrite", times:=1)
{
    put(putMode, times)
    moveCursor("right")
}

putToMouse()
{
    send, {lbutton}
    putLeft("insert")
}

undo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}Z{ctrl up}
    }
}

replaceWithRest()
{
    send, r
}

insertBeat()
{
    send, {insert}
}

insertBeatToBeginning()
{
    send, {home}{insert}
}

appendBeat()
{
    if (isBarEnd(false))
        send, {left}cr
    else
        send, {insert}r
}

appendBeatToEnd()
{
    send, {end}
    appendBeat()
}

insertBar()
{
    send, {ctrl down}{insert}{ctrl up}
}

appendBar()
{
    ; FIXME: Creates 2 empty bars if called on the last bar
    goToBeginningOfNextBar()
    insertBar()
}

transposeUp(times:=1)
{
    loop, %times%
    {
        ; send, {alt}nuu{enter}
        send, {alt}{right 4}{down 19}{enter}
    }
}

transposeDown(times:=1)
{
    loop, %times%
    {
        send, {alt}{right 4}{down 20}{enter}
    }
}

deselect()
{
    send, {escape}
}

joinBars(times:=1)
{
    goToBeginningOfNextBar(times)
    loop, %times%
    {
        selectBeatsToEnd()
        delete()
        send, {home}{left}c
        put("insert")
        send, {right}{ctrl down}{delete}{ctrl up}
        if (times > 1)
            goToBeginning()
    }
}
