NODEMON = nodemon
GPVIDIR = gpvi
GPVI = $(GPVIDIR)\gpvi.ahk
AUTOHOTKEY = "c:\Program Files\AutoHotkey\AutoHotkey.exe"

.PHONY: watch

watch:
	$(NODEMON) -w $(GPVIDIR) -x $(AUTOHOTKEY) /r $(GPVI)
