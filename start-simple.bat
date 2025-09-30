@echo off
chcp 65001 >nul
echo 🚀 启动 AI 小说工具箱简化版开发环境...
echo.

:: 检查 Node.js 是否安装
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js 未安装，请先安装 Node.js 18+
    echo    下载地址: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js 已安装

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
    copy .env.simple .env >nul
    echo ✅ 已创建 .env 文件
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
echo ✅ 环境配置完成！
echo.
echo 📝 重要：请编辑 backend\.env 文件，配置 DeepSeek API 密钥
echo     DEEPSEEK_API_KEY=your-deepseek-api-key-here
echo.
echo 🚀 启动服务：
echo.
echo    rem 终端1 - 启动后端服务
echo    cd backend ^&^& npm run dev
echo.
echo    rem 终端2 - 启动前端服务  
echo    cd frontend ^&^& npm run dev
echo.
echo 🌐 访问地址: http://localhost:3000
echo.
echo 💡 提示：此版本使用 SQLite 数据库，无需安装 PostgreSQL 和 Redis
echo.
pause
