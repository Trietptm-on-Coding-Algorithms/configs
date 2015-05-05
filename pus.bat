@echo OFF
setlocal ENABLEEXTENSIONS
set KEY_NAME="HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions"

FOR /F "usebackq" %%A IN (`REG QUERY %KEY_NAME% 2^>nul`) DO (
    FOR /F "tokens=6 delims=\" %%B IN ("%%A") DO (
        if "%1" == "list" (
            echo %%B
        ) else (
            @echo ON
            echo %%B | findstr /mi %1 >nul 2>&1
            if not errorlevel 1 (
               echo ^[+] loading sessiong ... %%B
               PLINK.EXE -load %%B
            )
            @echo OFF
        )
    )
)
