@echo off

REM This is a beta installer script that is the first step
REM in making the installation process painless. All you have
REM to do is run this. It will install Miniconda3 if you don't
REM have a conda installation. A shortcut should be
REM created for LPHK in the main LPHK folder! Just copy that
REM wherever you want, but don't move the LPHK folder, or it
REM will break the shortcut.

REM Please let me know if this does or does not work in the Discord!

set "LPHKENV="
set "LPHKPYTHON="
set "STARTPATH="
set "MAINDIR="
set "LPHKSCRIPT="
set "LINKPATH="
set "LPHKICON="
set "SHORTCUTSCRIPT="

where conda >nul 2>nul
if %ERRORLEVEL% EQU 0 goto CONDADONE

:NOCONDA
set "AREYOUSURE="
set /P AREYOUSURE=No conda found. Install Miniconda3? (Y/[N]) 
if /I "%AREYOUSURE%" EQU "Y" goto INSTALLCONDA
goto NOINSTALLCONDA

:INSTALLCONDA
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
if %OS%==32BIT set MCLINK=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86.exe
if %OS%==64BIT set MCLINK=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe

set CONDAEXE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%-condainstall.exe

echo Downloading Miniconda3...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%MCLINK%', '%CONDAEXE%')" > nul
if errorlevel 1 goto ERROREND

echo Installing Miniconda3...
start /wait /min %CONDAEXE% /InstallationType=JustMe /S /D=%USERPROFILE%\Miniconda3
if errorlevel 1 goto CONDAERROR
if not exist %USERPROFILE%\Miniconda3\ (goto CONDAERROR)

%USERPROFILE%\Miniconda3\Scripts\conda.exe init
if errorlevel 1 goto CONDAERROR

echo Miniconda3 has been installed...
echo Please re-run this installer in order to install LPHK!
del %CONDAEXE%
goto END

:CONDAERROR
echo Miniconda3 install failed!
del %CONDAEXE%
goto ERROREND

:CONDADONE
FOR /F "tokens=*" %%g IN ('conda env list ^| findstr /R /C:"LPHK"') do (set LPHKENV=%%g)
if defined LPHKENV goto ALREADYINSTALLED

set "AREYOUSURE="
set /P AREYOUSURE=Install LPHK? (Y/[N]) 
if /I "%AREYOUSURE%" EQU "Y" goto INSTALLLPHK
goto NOINSTALLLPHK

:INSTALLLPHK
echo Installing LPHK...
set STARTPATH=%CD%
cd %~dp0
call conda env create -f environment.yml
if errorlevel 1 goto INSTALLLPHKFAIL

call conda activate LPHK
FOR /F "tokens=*" %%g IN ('where python ^| findstr /R /C:"LPHK"') do (set LPHKPYTHON=%%g)
call conda deactivate
if errorlevel 1 goto INSTALLLPHKFAIL

cd ..
set MAINDIR=%CD%
cd %STARTPATH%

set LPHKSCRIPT=%MAINDIR%\LPHK.py

set LINKPATH=%MAINDIR%\LPHK.lnk
set LPHKICON=%MAINDIR%\resources\LPHK.ico

set SHORTCUTSCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SHORTCUTSCRIPT%
echo sLinkFile = "%LINKPATH%" >> %SHORTCUTSCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SHORTCUTSCRIPT%
echo oLink.TargetPath = "%LPHKPYTHON%" >> %SHORTCUTSCRIPT%
echo oLink.Arguments = "%LPHKSCRIPT%" >> %SHORTCUTSCRIPT%
echo oLink.IconLocation = "%LPHKICON%" >> %SHORTCUTSCRIPT%
echo oLink.Save >> %SHORTCUTSCRIPT%
call cscript /nologo %SHORTCUTSCRIPT%
del %SHORTCUTSCRIPT%
if errorlevel 1 goto INSTALLLPHKFAIL
goto DESKTOPLINKMAKE

:INSTALLLPHKFAIL
call conda env remove -n LPHK
rmdir %USERPROFILE%\Miniconda3\envs\LPHK /s /q > nul
goto ERROREND

:ALREADYINSTALLED
echo LPHK is already installed!
set "AREYOUSURE="
set /P AREYOUSURE=Uninstall LPHK? (Y/[N]) 
if /I "%AREYOUSURE%" EQU "Y" goto UNINSTALLLPHK
goto NOUNINSTALLLPHK

:UNINSTALLLPHK
echo Uninstalling LPHK...
call conda env remove -n LPHK
rmdir %USERPROFILE%\Miniconda3\envs\LPHK /s /q > nul
if errorlevel 1 goto ERROREND

echo LPHK conda environment unistalled.
echo Please manually delete shortcuts, program files, and if desired, uninstall Miniconda3.
echo Run this installer again ro re-install.
goto END

:NOUNINSTALLLPHK
echo Not uninstalling LPHK, exiting...
goto END

:NOINSTALLLPHK
echo Not installing LPHK, exiting...
goto END

:NOINSTALLCONDA
echo Not installing MiniConda3, exiting...
goto END

:NOINSTALLCONDA
echo Not installing LPHK, exiting...
goto END

:DESKTOPLINKMAKE
echo Installation done! Shortcut created at %LINKPATH%

set "AREYOUSURE="
set /P AREYOUSURE=Install desktop shortcut? (Y/[N])
if /I "%AREYOUSURE%" EQU "Y" goto INSTALLSHORTCUT

echo Run this installer again to uninstall LPHK.
goto END

:INSTALLSHORTCUT
set DESKTOPLINK=%USERPROFILE%\Desktop\
copy "%LINKPATH%" "%DESKTOPLINK%"
if errorlevel 1 goto ERROREND

echo Copied shortcut to desktop.
echo Run this installer again to uninstall LPHK.
goto END

:ERROREND
echo The installer has failed!
echo Please try running again, or seek help in the Discord.
goto END

:END
echo LPHK installer is done running.
pause