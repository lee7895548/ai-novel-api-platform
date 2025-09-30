@echo off
chcp 65001 >nul
echo 🚀 启动 AI 小说工具箱商业化平台开发环境...
echo.

:: 检查 Node.js 是否安装
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js 未安装，请先安装 Node.js 18+
    pause
    exit /b 1
)

:: 检查 PostgreSQL 是否运行
echo 📊 检查数据库服务...
pg_isready -h localhost -p 5432 >nul 2>&1
if errorlevel 1 (
    echo ⚠️  PostgreSQL 未运行，请先启动 PostgreSQL 服务
    echo     请确保 PostgreSQL 服务正在运行
    pause
    exit /b 1
)

:: 检查 Redis 是否运行
echo 🔴 检查 Redis 服务...
redis-cli ping >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Redis 未运行，请先启动 Redis 服务
    echo     请确保 Redis 服务正在运行
    pause
    exit /b 1
)

:: 创建数据库（如果不存在）
echo 🗄️  初始化数据库...
createdb ai_novel_platform >nul 2>&1
if errorlevel 1 (
    echo 数据库已存在或创建失败
)

:: 安装后端依赖
echo 📦 安装后端依赖...
cd backend
if not exist "node_modules" (
    npm install
) else (
    echo 后端依赖已安装
)

:: 复制环境配置
if not exist ".env" (
    copy .env.example .env >nul
    echo ✅ 已创建 .env 文件，请编辑配置 DeepSeek API 密钥
)

:: 安装前端依赖
echo 📦 安装前端依赖...
cd ..\frontend
if not exist "node_modules" (
    npm install
) else (
    echo 前端依赖已安装
)

:: 回到项目根目录
cd ..

echo.
echo ✅ 环境检查完成！
echo.
echo 📝 下一步操作：
echo 1. 编辑 backend\.env 文件，配置 DeepSeek API 密钥
echo 2. 运行以下命令启动服务：
echo.
echo    rem 终端1 - 启动后端
echo    cd backend ^&^& npm run dev
echo.
echo    rem 终端2 - 启动前端
echo    cd frontend ^&^& npm run dev
echo.
echo 3. 访问 http://localhost:3000 使用平台
echo.
pause
