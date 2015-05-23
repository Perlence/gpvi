_openProcess(processId, desiredAccess:=0x10, inheritHandle:=false)
{
    return dllCall("OpenProcess"
                  , UInt, desiredAccess
                  , Char, inheritHandle
                  , UInt, processId)
}

_closeHandle(hProcess)
{
    dllCall("CloseHandle"
           , UInt, hProcess)
}

_readProcessMemory(hProcess, baseAddress, type, size:="")
{
    global TYPE_SIZES
    size := size ? size : TYPE_SIZES[type]
    varSetCapacity(buffer, size, 0)
    result := dllCall("ReadProcessMemory"
                     , UInt, hProcess
                     , UPtr, baseAddress
                     , UInt, &buffer
                     , UInt, size
                     , UPtr, 0)
    if type in Str,AStr,WStr
    {
        data := strGet(&buffer, size, "")
    }
    else
    {
        data := numGet(buffer, , type)
    }
    return data
}

getHProcess()
{
    global GP_VERSION_BASE_ADDR, WIN_TITLE
    global hProcess, gpVersion
    if (hProcess)
        return hProcess
    winGet, pid, pid, %WIN_TITLE%
    hProcess := _openProcess(pid)
    return hProcess
}

getGuitarProVersion(hProcess)
{
    global GP_VERSION_BASE_ADDR
    global gpVersion
    if (gpVersion)
        return gpVersion
    for version, baseAddr in GP_VERSION_BASE_ADDR
    {
        value := _readProcessMemory(hProcess, baseAddr, "Str", 3)
        if (version = value)
            return gpVersion := version
    }
}

/**
 * Read data located in [[baseAddress]+offset].
 *
 * @param {UInt or Object} baseAddress - if Object given, it should
 *   contain base addresses corresponding to a particular Guitar Pro
 *   version (see `CURSOR_BASE_ADDR`).
 * @param {Int} offset
 * @param {Str} type - name of AutoHotkey type.
 * @return data read from given base address by given offset.
 */
readOffset(baseAddressIntOrObject, offset, type)
{
    hProcess := getHProcess()
    if (isObject(baseAddressIntOrObject))
    {
        gpVersion := getGuitarProVersion(hProcess)
        baseAddress := baseAddressIntOrObject[gpVersion]
    }
    else
    {
        baseAddress := baseAddressIntOrObject
    }
    startAddr := _readProcessMemory(hProcess, baseAddress, "UInt")
    return _readProcessMemory(hProcess, (startAddr + offset), type)
}

/**
 * Use memory magic to check if user selected beats of bars.
 */
getSelectionMode()
{
    global CURSOR_BASE_ADDR, IS_SELECTED_OFFSET
    selected := readOffset(CURSOR_BASE_ADDR, IS_SELECTED_OFFSET, "UShort")
    if (selected = 0x01)
        return "beats"
    else if (selected = 0x0101)
        return "bars"
    else
        return ""
}

/**
 * Use memory magic to determine cursor position in current bar.
 *
 * @return {Array of UInt} cursor position [beat, string]
 */
getCursorPosition()
{
    global CURSOR_BASE_ADDR, CURSOR_X_OFFSET, CURSOR_Y_OFFSET, CURSOR_DELAY
    sleep, %CURSOR_DELAY%
    cursorX := readOffset(CURSOR_BASE_ADDR, CURSOR_X_OFFSET, "UInt")
    cursorY := readOffset(CURSOR_BASE_ADDR, CURSOR_Y_OFFSET, "UInt")
    return [cursorX, cursorY]
}

/**
 * Use memory magic to determine current bar number.
 *
 * @return {UInt} current bar.
 */
getCurrentBar()
{
    global CURSOR_BASE_ADDR, CURSOR_BAR_OFFSET, CURSOR_DELAY
    sleep, %CURSOR_DELAY%
    return readOffset(CURSOR_BASE_ADDR, CURSOR_BAR_OFFSET, "UInt")
}

/**
 * Check if cursor is on the first beat of the current bar
 */
isBarStart()
{
    cursorX1 := getCursorPosition()[1]
    return (cursorX1 = 1)
}

/**
 * Check if cursor is on the last beat of the current bar
 *
 * @param {Bool} returnBack - the function moves cursor to the left to
 *   check if cursor position became 1, then it moves cursor back. Set
 *   this argument to `false` to not go left.
 */
isBarEnd(returnBack:=true)
{
    ; FIXME: Creates empty bar in the end if testing on the last beat of
    ; the last bar.
    cursorX1 := getCursorPosition()[1]
    moveCursor("right")
    cursorX2 := getCursorPosition()[1]
    result := (cursorX2 = 1 or cursorX1 = cursorX2)
    if (returnBack and cursorX1 != cursorX2)
        moveCursor("left")
    return result
}
