#!/bin/bash

echo "🚀 启动 AI 小说工具箱商业化平台开发环境..."

# 检查 Node.js 是否安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js 18+"
    exit 1
fi

# 检查 PostgreSQL 是否运行
echo "📊 检查数据库服务..."
if ! pg_isready -h localhost -p 5432 &> /dev/null; then
    echo "⚠️  PostgreSQL 未运行，请先启动 PostgreSQL 服务"
    echo "    Windows: 启动 PostgreSQL 服务"
    echo "    macOS: brew services start postgresql"
    echo "    Linux: sudo systemctl start postgresql"
    exit 1
fi

# 检查 Redis 是否运行
echo "🔴 检查 Redis 服务..."
if ! redis-cli ping &> /dev/null; then
    echo "⚠️  Redis 未运行，请先启动 Redis 服务"
    echo "    Windows: 下载并运行 Redis"
    echo "    macOS: brew services start redis"
    echo "    Linux: sudo systemctl start redis"
    exit 1
fi

# 创建数据库（如果不存在）
echo "🗄️  初始化数据库..."
createdb ai_novel_platform 2>/dev/null || echo "数据库已存在"

# 安装后端依赖
echo "📦 安装后端依赖..."
cd backend
if [ ! -d "node_modules" ]; then
    npm install
fi

# 复制环境配置
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ 已创建 .env 文件，请编辑配置 DeepSeek API 密钥"
fi

# 安装前端依赖
echo "📦 安装前端依赖..."
cd ../frontend
if [ ! -d "node_modules" ]; then
    npm install
fi

# 回到项目根目录
cd ..

echo ""
echo "✅ 环境检查完成！"
echo ""
echo "📝 下一步操作："
echo "1. 编辑 backend/.env 文件，配置 DeepSeek API 密钥"
echo "2. 运行以下命令启动服务："
echo ""
echo "   # 终端1 - 启动后端"
echo "   cd backend && npm run dev"
echo ""
echo "   # 终端2 - 启动前端"  
echo "   cd frontend && npm run dev"
echo ""
echo "3. 访问 http://localhost:3000 使用平台"
echo ""
