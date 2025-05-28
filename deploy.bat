@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 早护通后端部署脚本 (Windows版本)
REM 使用方法: deploy.bat [环境] [操作]
REM 环境: dev|prod
REM 操作: build|start|stop|restart|logs|status

set "env=dev"
set "action=help"

REM 解析参数
if "%1"=="" goto :parse_done
if "%1"=="dev" (
    set "env=dev"
    if not "%2"=="" (
        set "action=%2"
    ) else (
        set "action=start"
    )
) else if "%1"=="prod" (
    set "env=prod"
    if not "%2"=="" (
        set "action=%2"
    ) else (
        set "action=start"
    )
) else (
    set "action=%1"
)
:parse_done

REM 检查Docker是否安装
if not "%action%"=="help" (
    call :check_docker
    if errorlevel 1 exit /b 1
)

REM 检查环境文件
if not "%action%"=="help" (
    if not "%action%"=="cleanup" (
        call :check_env_file
        if errorlevel 1 exit /b 1
    )
)

REM 执行操作
if "%action%"=="build" (
    call :build_image
) else if "%action%"=="start" (
    call :start_service
) else if "%action%"=="stop" (
    call :stop_service
) else if "%action%"=="restart" (
    call :restart_service
) else if "%action%"=="logs" (
    call :show_logs
) else if "%action%"=="status" (
    call :show_status
) else if "%action%"=="cleanup" (
    call :cleanup
) else if "%action%"=="backup" (
    call :backup_data
) else if "%action%"=="update" (
    call :update_deployment
) else if "%action%"=="help" (
    call :show_help
) else (
    echo [错误] 未知操作: %action%
    call :show_help
    exit /b 1
)

goto :eof

REM 检查Docker是否安装
:check_docker
echo [信息] 检查Docker安装状态...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [错误] Docker未安装，请先安装Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [错误] Docker Compose未安装，请先安装Docker Compose
    exit /b 1
)

echo [成功] Docker环境检查通过
goto :eof

REM 检查环境文件
:check_env_file
set "env_file=.env"
if "%env%"=="prod" set "env_file=.env.prod"

if not exist "%env_file%" (
    echo [警告] 环境文件 %env_file% 不存在
    if exist ".env.example" (
        echo [信息] 复制 .env.example 到 %env_file%
        copy ".env.example" "%env_file%" >nul
        echo [警告] 请编辑 %env_file% 文件并填入正确的配置值
    ) else (
        echo [错误] 请创建 %env_file% 文件
        exit /b 1
    )
)
goto :eof

REM 构建镜像
:build_image
echo [信息] 开始构建Docker镜像...
if "%env%"=="prod" (
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
) else (
    docker-compose build
)
if errorlevel 1 (
    echo [错误] Docker镜像构建失败
    exit /b 1
)
echo [成功] Docker镜像构建完成
goto :eof

REM 启动服务
:start_service
echo [信息] 启动服务...
if "%env%"=="prod" (
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
) else (
    docker-compose up -d
)
if errorlevel 1 (
    echo [错误] 服务启动失败
    exit /b 1
)
echo [成功] 服务启动完成
call :show_status
goto :eof

REM 停止服务
:stop_service
echo [信息] 停止服务...
if "%env%"=="prod" (
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
) else (
    docker-compose down
)
echo [成功] 服务已停止
goto :eof

REM 重启服务
:restart_service
echo [信息] 重启服务...
call :stop_service
call :start_service
goto :eof

REM 查看日志
:show_logs
echo [信息] 查看服务日志...
if "%env%"=="prod" (
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f
) else (
    docker-compose logs -f
)
goto :eof

REM 查看状态
:show_status
echo [信息] 服务状态:
docker-compose ps
echo.
echo [信息] 健康检查:

REM 等待服务启动
timeout /t 5 /nobreak >nul

REM 检查健康状态
curl -f http://localhost:5000/api/health >nul 2>&1
if errorlevel 1 (
    echo [错误] API服务无法访问
    echo [信息] 请检查日志: deploy.bat %env% logs
) else (
    echo [成功] API服务正常运行
    echo 访问地址: http://localhost:5000
    echo 健康检查: http://localhost:5000/api/health
    echo API文档: 请查看 API测试指南.md
)
goto :eof

REM 清理资源
:cleanup
echo [信息] 清理Docker资源...

REM 停止并删除容器
docker-compose down --remove-orphans

REM 删除未使用的镜像
docker image prune -f

REM 删除未使用的卷
docker volume prune -f

echo [成功] 清理完成
goto :eof

REM 备份数据
:backup_data
echo [信息] 备份数据库...

set "backup_dir=backups"
if not exist "%backup_dir%" mkdir "%backup_dir%"

for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set "date_str=%%d%%b%%c"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "time_str=%%a%%b"
set "timestamp=%date_str%_%time_str%"
set "backup_file=%backup_dir%\database_%timestamp%.db"

if exist "instance\database.db" (
    copy "instance\database.db" "%backup_file%" >nul
    echo [成功] 数据库备份完成: %backup_file%
) else (
    echo [警告] 数据库文件不存在
)
goto :eof

REM 更新部署
:update_deployment
echo [信息] 更新部署...

REM 备份数据
call :backup_data

REM 拉取最新代码（如果是git仓库）
if exist ".git" (
    echo [信息] 拉取最新代码...
    git pull
)

REM 重新构建和启动
call :build_image
call :restart_service

echo [成功] 更新部署完成
goto :eof

REM 显示帮助信息
:show_help
echo 早护通后端部署脚本 (Windows版本)
echo.
echo 使用方法:
echo   %~nx0 [环境] [操作]
echo.
echo 环境:
echo   dev   - 开发环境（默认）
echo   prod  - 生产环境
echo.
echo 操作:
echo   build    - 构建Docker镜像
echo   start    - 启动服务
echo   stop     - 停止服务
echo   restart  - 重启服务
echo   logs     - 查看日志
echo   status   - 查看状态
echo   cleanup  - 清理Docker资源
echo   backup   - 备份数据库
echo   update   - 更新部署
echo   help     - 显示帮助信息
echo.
echo 示例:
echo   %~nx0 dev start     # 开发环境启动服务
echo   %~nx0 prod restart  # 生产环境重启服务
echo   %~nx0 dev logs      # 查看开发环境日志
echo.
echo 注意事项:
echo   1. 请确保已安装Docker Desktop
echo   2. 首次运行前请配置.env文件
echo   3. 生产环境请使用.env.prod文件
goto :eof