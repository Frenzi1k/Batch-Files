@ECHO Off
:begin
setlocal EnableDelayedExpansion
set confirm = ""
echo Format disk? [yes/no]
call :readLine
if "%confirm%" == "yes" (
	echo Are you sure about this? [yes/no]
	call :readLine
	if "!confirm!" == "yes" (
		@echo Done. You're looking at a blue screen now
	) else (
		if "!confirm!" == "no" (
			@echo I've done nothing. See you next time
			pause
			exit 1
		) else (
			goto error
		)
	)	
) else (
	if "%confirm%" == "no" (
		exit 1
	) else (
		goto error
	)
)
pause

:readLine
SET /p confirm=""
goto :EOF

:error
@echo You must type "yes" or "no"!
goto begin
