NODEMON = nodemon
GPVI = gpvi.ahk
AUTOHOTKEY = "c:\Program Files\AutoHotkey\AutoHotkey.exe"

.PHONY: watch

watch:
	$(NODEMON) -w $(GPVI) -x $(AUTOHOTKEY) /r $(GPVI)
