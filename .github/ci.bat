@echo off
rem .github\ci.bat - Windows CI script

echo [ci.bat] Starting CI script on %COMPUTERNAME%

cd HelloProject || (echo HelloProject directory not found & exit /b 2)

if exist gradlew.bat (
  echo [ci.bat] Using Gradle Wrapper
  gradlew.bat clean test || (echo Gradle Wrapper build failed & exit /b %errorlevel%)
) else (
  where gradle >nul 2>&1
  if %ERRORLEVEL%==0 (
    echo [ci.bat] Using system Gradle
    gradle --no-daemon clean test || (echo Gradle build failed & exit /b %errorlevel%)
  ) else (
    echo [ci.bat] Gradle not found. Falling back to javac/java compile/run for basic check.
    if not exist out (mkdir out)
    for /r %%f in (src\*.java) do (
      echo Compiling %%f
      javac -d out "%%f" || (echo Compilation failed & exit /b 3)
    )
    if exist out\Main.class (
      echo Running Main
      java -cp out Main || (echo Runtime failed & exit /b %errorlevel%)
    ) else (
      echo Main.class not found after compilation & exit /b 4
    )
  )
)

echo [ci.bat] CI script finished successfully
