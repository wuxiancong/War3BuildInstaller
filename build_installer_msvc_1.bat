@echo off
chcp 65001 >nul

set LOG_FILE=build_installer_msvc.log

echo 简化打包 - MSVC 版本... > "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 开始时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo 简化打包 - MSVC 版本...

set BUILD_DIR=D:\Qt_\War3Launcher\build\Desktop_Qt_5_15_2_MSVC2019_32bit-Release
set DEPLOY_DIR=D:\Qt_\War3Launcher\deploy\msvc
set INSTALLER_DIR=MSVC\War3Launcher
set WINDEPLOYQT=D:\Qt\5.15.2\msvc2019\bin\windeployqt.exe
set BINARYCREATOR=D:\Qt\Tools\QtInstallerFramework\4.9\bin\binarycreator.exe
set SOURCE_DIR=D:\Qt_\War3Launcher

echo 1. 清理目录... >> "%LOG_FILE%"
echo 1. 清理目录...
if exist "%DEPLOY_DIR%" rmdir /s /q "%DEPLOY_DIR%"
if exist "%INSTALLER_DIR%" rmdir /s /q "%INSTALLER_DIR%"

mkdir "%DEPLOY_DIR%"
mkdir "%INSTALLER_DIR%"
echo ✓ 目录清理完成 >> "%LOG_FILE%"

echo 2. 检查主程序... >> "%LOG_FILE%"
echo 2. 检查主程序...
if not exist "%BUILD_DIR%\War3Launcher.exe" (
    echo 错误: 找不到 %BUILD_DIR%\War3Launcher.exe >> "%LOG_FILE%"
    echo 错误: 找不到主程序，请先编译项目!
    pause
    exit /b 1
)
echo ✓ 找到 War3Launcher.exe >> "%LOG_FILE%"

echo 3. 复制主程序和资源... >> "%LOG_FILE%"
echo 3. 复制主程序和资源...
copy "%BUILD_DIR%\War3Launcher.exe" "%DEPLOY_DIR%\"
if exist "%BUILD_DIR%\hook.dll" copy "%BUILD_DIR%\hook.dll" "%DEPLOY_DIR%\"
if exist "%BUILD_DIR%\load.dll" copy "%BUILD_DIR%\load.dll" "%DEPLOY_DIR%\"
if exist "%BUILD_DIR%\DebugConfig.ini" copy "%BUILD_DIR%\DebugConfig.ini" "%DEPLOY_DIR%\"
if exist "%BUILD_DIR%\images" xcopy "%BUILD_DIR%\images" "%DEPLOY_DIR%\images\" /e /y /i
echo ✓ 文件复制完成 >> "%LOG_FILE%"

:: ========== 处理 logs 文件夹 ==========
echo 处理日志目录... >> "%LOG_FILE%"
echo 处理日志目录...

:: 确保 BUILD_DIR 下的 logs 目录存在
if not exist "%BUILD_DIR%\logs" (
    mkdir "%BUILD_DIR%\logs"
    echo ✓ 创建日志目录: %BUILD_DIR%\logs >> "%LOG_FILE%"
    echo ✓ 创建日志目录: %BUILD_DIR%\logs
) else (
    :: 清空 BUILD_DIR 中的 logs 目录内容
    if exist "%BUILD_DIR%\logs\*" (
        del "%BUILD_DIR%\logs\*" /q
        echo ✓ 已清空构建目录中的日志文件夹 >> "%LOG_FILE%"
        echo ✓ 已清空构建目录中的日志文件夹
    )
)

:: 复制 BUILD_DIR 的 logs 目录到 DEPLOY_DIR
if exist "%BUILD_DIR%\logs" (
    :: 清空 DEPLOY_DIR 中的 logs 目录（如果存在）
    if exist "%DEPLOY_DIR%\logs" (
        rmdir "%DEPLOY_DIR%\logs" /s /q
    )
    
    xcopy "%BUILD_DIR%\logs" "%DEPLOY_DIR%\logs\" /e /y /i
    echo ✓ 日志目录复制完成: %BUILD_DIR%\logs → %DEPLOY_DIR%\logs >> "%LOG_FILE%"
    echo ✓ 日志目录复制完成: %BUILD_DIR%\logs → %DEPLOY_DIR%\logs
) else (
    echo ✗ 日志目录不存在: %BUILD_DIR%\logs >> "%LOG_FILE%"
    echo ✗ 日志目录不存在: %BUILD_DIR%\logs
)
:: ==================================================

echo ✓ 目录清理完成 >> "%LOG_FILE%"

echo 4. 使用 windeployqt 自动部署依赖... >> "%LOG_FILE%"
echo 4. 使用 windeployqt 自动部署依赖...
if exist "%WINDEPLOYQT%" (
    echo 执行: windeployqt --qmldir "%SOURCE_DIR%" --dir "%DEPLOY_DIR%" "%DEPLOY_DIR%\War3Launcher.exe" >> "%LOG_FILE%"
    "%WINDEPLOYQT%" --qmldir "%SOURCE_DIR%" --dir "%DEPLOY_DIR%" "%DEPLOY_DIR%\War3Launcher.exe"
    echo ✓ windeployqt 部署完成 >> "%LOG_FILE%"
) else (
    echo 错误: 找不到 windeployqt.exe >> "%LOG_FILE%"
    echo 错误: 找不到 windeployqt.exe
    pause
    exit /b 1
)

echo 5. 创建安装包结构... >> "%LOG_FILE%"
echo 5. 创建安装包结构...
mkdir "%INSTALLER_DIR%\config"
mkdir "%INSTALLER_DIR%\packages"
mkdir "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher"
mkdir "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\data"
mkdir "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta"
echo ✓ 安装包结构创建完成 >> "%LOG_FILE%"

echo 6. 复制文件到安装包... >> "%LOG_FILE%"
echo 6. 复制文件到安装包...
xcopy "%DEPLOY_DIR%\*" "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\data\" /e /y /i
echo ✓ 文件复制到安装包完成 >> "%LOG_FILE%"

echo 7. 复制安装程序资源文件... >> "%LOG_FILE%"
echo 7. 复制安装程序资源文件...
if exist "%SOURCE_DIR%\images\installer-background.png" (
    copy "%SOURCE_DIR%\images\installer-background.png" "%INSTALLER_DIR%\config\"
    echo ✓ 复制 installer-background.png >> "%LOG_FILE%"
) else (
    echo ⚠ 找不到 installer-background.png >> "%LOG_FILE%"
)

if exist "%SOURCE_DIR%\images\installer-banner.png" (
    copy "%SOURCE_DIR%\images\installer-banner.png" "%INSTALLER_DIR%\config\"
    echo ✓ 复制 installer-banner.png >> "%LOG_FILE%"
) else (
    echo ⚠ 找不到 installer-banner.png >> "%LOG_FILE%"
)

if exist "%SOURCE_DIR%\images\installer-icon.ico" (
    copy "%SOURCE_DIR%\images\installer-icon.ico" "%INSTALLER_DIR%\config\"
    echo ✓ 复制 installer-icon.ico >> "%LOG_FILE%"
) else (
    echo ⚠ 找不到 installer-icon.ico >> "%LOG_FILE%"
)

if exist "%SOURCE_DIR%\images\installer-logo.png" (
    copy "%SOURCE_DIR%\images\installer-logo.png" "%INSTALLER_DIR%\config\"
    echo ✓ 复制 installer-logo.png >> "%LOG_FILE%"
) else (
    echo ⚠ 找不到 installer-logo.png >> "%LOG_FILE%"
)

echo 8. 验证关键文件... >> "%LOG_FILE%"
echo 8. 验证关键文件...
set KEY_FILES=War3Launcher.exe hook.dll load.dll Qt5Core.dll Qt5Quick.dll

for %%F in (%KEY_FILES%) do (
    if exist "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\data\%%F" (
        echo ✓ %%F 存在 >> "%LOG_FILE%"
    ) else (
        echo ✗ %%F 缺失 >> "%LOG_FILE%"
    )
)

echo 9. 创建配置文件... >> "%LOG_FILE%"
echo 9. 创建配置文件...

REM 创建 config.xml（包含安装程序图片引用）
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%INSTALLER_DIR%\config\config.xml"
echo ^<Installer^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Name^>War3Launcher^</Name^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Version^>1.0.0^</Version^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Title^>War3Launcher Installer^</Title^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Publisher^>wuxiancong^</Publisher^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<StartMenuDir^>War3Launcher^</StartMenuDir^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<TargetDir^>C:/Program Files (x86)/War3Launcher^</TargetDir^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Logo^>installer-logo.png^</Logo^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Banner^>installer-banner.png^</Banner^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<Background^>installer-background.png^</Background^> >> "%INSTALLER_DIR%\config\config.xml"
echo     ^<RunProgram^>@TargetDir@/War3Launcher.exe^</RunProgram^> >> "%INSTALLER_DIR%\config\config.xml"
echo ^</Installer^> >> "%INSTALLER_DIR%\config\config.xml"

REM 创建 package.xml
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo ^<Package^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo     ^<DisplayName^>War3Launcher^</DisplayName^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo     ^<Description^>WarCraft III Game Launcher^</Description^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo     ^<Version^>1.0.0^</Version^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo     ^<ReleaseDate^>2025-10-17^</ReleaseDate^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo     ^<Default^>true^</Default^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"
echo ^</Package^> >> "%INSTALLER_DIR%\packages\com.wuxiancong.war3launcher\meta\package.xml"

echo ✓ 配置文件创建完成 >> "%LOG_FILE%"

echo 10. 生成安装程序... >> "%LOG_FILE%"
echo 10. 生成安装程序...
cd /d "%INSTALLER_DIR%"
echo 执行: binarycreator -f -c config/config.xml -p packages War3Launcher_MSVC_Installer.exe >> "%LOG_FILE%"
"%BINARYCREATOR%" -f -c config/config.xml -p packages War3Launcher_MSVC_Installer.exe

if exist "War3Launcher_MSVC_Installer.exe" (
    echo. >> "%LOG_FILE%"
    echo ✓ 打包成功! >> "%LOG_FILE%"
    echo 安装程序: %CD%\War3Launcher_MSVC_Installer.exe >> "%LOG_FILE%"
    for %%F in ("War3Launcher_MSVC_Installer.exe") do echo 文件大小: %%~zF 字节 >> "%LOG_FILE%"
    
    echo.
    echo ========================================
    echo ✓ 打包成功!
    echo 安装程序: %CD%\War3Launcher_MSVC_Installer.exe
    for %%F in ("War3Launcher_MSVC_Installer.exe") do echo 文件大小: %%~zF 字节
    echo ========================================
    
    REM 复制安装程序到源码目录和部署目录
    copy "War3Launcher_MSVC_Installer.exe" "%SOURCE_DIR%\deploy\" >nul 2>&1
    if exist "%SOURCE_DIR%\deploy\War3Launcher_MSVC_Installer.exe" (
        echo ✓ 安装程序已复制到源码目录 >> "%LOG_FILE%"
    )
    
    copy "War3Launcher_MSVC_Installer.exe" "%DEPLOY_DIR%\" >nul 2>&1
    if exist "%DEPLOY_DIR%\War3Launcher_MSVC_Installer.exe" (
        echo ✓ 安装程序已复制到部署目录 >> "%LOG_FILE%"
    )
) else (
    echo. >> "%LOG_FILE%"
    echo ✗ 打包失败! >> "%LOG_FILE%"
    echo.
    echo ✗ 打包失败!
)

echo. >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 结束时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

echo.
echo 详细日志已保存到: %LOG_FILE%
pause