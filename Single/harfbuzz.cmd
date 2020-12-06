@echo off
SETLOCAL EnableDelayedExpansion
Color A

set VCMakeRootPath=%1
set dbyoungSDKPath=%2
set InstallSDKPath=%3
set SourceCodeName=%4
set BuildPlatform_=%5
set BuildLanguageX=%6
set BuildHostX8664=%7
set VCProjectNameX=%8
set "PKG_CONFIG_PATH=%dbyoungSDKPath%\lib\pkgconfig"

:: 源代码目录
set "SourceFullPath=%VCMakeRootPath%Source\%SourceCodeName%"

:: 编译目录
set BuildharfbuzzPath=%VCMakeRootPath%VSBuild\%SourceCodeName%\%BuildHostX8664%

:: MSBuild 头文件、库文件搜索路径
set "INCLUDE=%dbyoungSDKPath%\include;%INCLUDE%"
set "LIB=%dbyoungSDKPath%\lib;%LIB%"
set "UseEnv=True"

:: meson 编译
if exist %BuildharfbuzzPath% (
  rd /S /Q %BuildharfbuzzPath%
)

meson --prefix=%InstallSDKPath% -Dbuildtype=release -Ddefault_library=static -Ddebug=false -Db_vscrt=mt -Dlibpng=disabled %SourceFullPath% %BuildharfbuzzPath%
cd /D %BuildharfbuzzPath%
ninja
ninja install

:: 检查 VC 编译是否有错误
if %ERRORLEVEL% NEQ 0 (
  echo 编译出现错误，停止编译
  pause
  goto bEnd
)

:: 安装之后 
copy /Y "%InstallSDKPath%\lib\libharfbuzz.a" "%InstallSDKPath%\lib\libharfbuzz.lib"
copy /Y "%InstallSDKPath%\lib\libharfbuzz-subset.a" "%InstallSDKPath%\lib\libharfbuzz-subset.lib"
copy /Y "%InstallSDKPath%\lib\libharfbuzz.a" "%InstallSDKPath%\lib\harfbuzz.lib"
copy /Y "%InstallSDKPath%\lib\libharfbuzz-subset.a" "%InstallSDKPath%\lib\harfbuzz-subset.lib"

:: 源代码还原
cd /D "%SourceFullPath%"
git clean -d  -fx -f
git checkout .

:bEnd
