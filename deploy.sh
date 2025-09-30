#!/bin/bash

# AI 小说工具箱商业化平台 - 一键部署脚本
# 支持多种部署方式：Docker Compose、Vercel+Railway、云服务器

set -e

echo "🚀 AI 小说工具箱商业化平台部署脚本"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数：打印彩色信息
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查依赖
check_dependencies() {
    info "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("Docker")
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("Docker Compose")
    fi
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("Git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "缺少必要的依赖: ${missing_deps[*]}"
        echo "请安装以下软件："
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi
    
    info "所有依赖检查通过"
}

# 环境变量配置
setup_environment() {
    info "配置环境变量..."
    
    if [ ! -f .env.production ]; then
        warn "创建生产环境配置文件..."
        cat > .env.production << EOF
# 生产环境配置
NODE_ENV=production
PORT=3001

# DeepSeek API 配置
DEEPSEEK_API_KEY=请在此处填写您的DeepSeek_API密钥
DEEPSEEK_API_URL=https://api.deepseek.com/chat/completions

# JWT 安全配置
JWT_SECRET=$(openssl rand -hex 32)

# 数据库配置
DATABASE_TYPE=sqlite
DATABASE_PATH=./data/ai_novel_platform.db

# 支付配置 (按需配置)
# STRIPE_SECRET_KEY=sk_test_...
# ALIPAY_APP_ID=your-alipay-app-id
# WECHAT_APP_ID=your-wechat-app-id

# 业务配置
FREE_TIER_WORD_LIMIT=1000
FREE_TIER_API_LIMIT=100
COST_PER_WORD=0.0001
EOF
        warn "请编辑 .env.production 文件，配置您的 DeepSeek API 密钥和其他设置"
    else
        info "生产环境配置文件已存在"
    fi
}

# Docker Compose 部署
deploy_docker_compose() {
    info "开始 Docker Compose 部署..."
    
    # 创建数据目录
    mkdir -p data
    
    # 复制环境变量
    if [ -f .env.production ]; then
        cp .env.production .env
    else
        error "找不到环境变量文件 .env.production"
        exit 1
    fi
    
    # 构建并启动服务
    docker-compose -f docker-compose.prod.yml build
    docker-compose -f docker-compose.prod.yml up -d
    
    info "Docker Compose 部署完成！"
    echo "前端访问地址: http://localhost"
    echo "后端API地址: http://localhost:3001"
    echo "健康检查: curl http://localhost:3001/health"
}

# Vercel 部署前端
deploy_vercel() {
    info "开始 Vercel 前端部署..."
    
    if ! command -v vercel &> /dev/null; then
        warn "Vercel CLI 未安装，正在安装..."
        npm install -g vercel
    fi
    
    cd frontend
    
    # 构建前端
    info "构建前端..."
    npm run build
    
    # 部署到 Vercel
    info "部署到 Vercel..."
    vercel --prod
    
    cd ..
    
    info "Vercel 部署完成！"
}

# Railway 部署后端
deploy_railway() {
    info "开始 Railway 后端部署..."
    
    if ! command -v railway &> /dev/null; then
        warn "Railway CLI 未安装，正在安装..."
        npm install -g @railway/cli
    fi
    
    cd backend
    
    # 部署到 Railway
    info "部署到 Railway..."
    railway deploy
    
    cd ..
    
    info "Railway 部署完成！"
}

# 云服务器部署
deploy_cloud() {
    info "开始云服务器部署..."
    
    # 构建 Docker 镜像
    info "构建 Docker 镜像..."
    docker build -t ai-novel-backend ./backend
    docker build -t ai-novel-frontend ./frontend
    
    # 保存镜像
    docker save ai-novel-backend -o ai-novel-backend.tar
    docker save ai-novel-frontend -o ai-novel-frontend.tar
    
    info "Docker 镜像已保存，可以上传到云服务器"
    echo "上传命令示例:"
    echo "  scp ai-novel-*.tar user@your-server:/path/"
    echo "  ssh user@your-server \"docker load -i ai-novel-backend.tar && docker load -i ai-novel-frontend.tar\""
    echo "  ssh user@your-server \"docker-compose -f docker-compose.prod.yml up -d\""
}

# 显示部署状态
show_status() {
    info "检查服务状态..."
    
    # 检查后端服务
    if curl -f http://localhost:3001/health &> /dev/null; then
        info "✅ 后端服务运行正常"
    else
        error "❌ 后端服务异常"
    fi
    
    # 检查前端服务
    if curl -f http://localhost &> /dev/null; then
        info "✅ 前端服务运行正常"
    else
        error "❌ 前端服务异常"
    fi
    
    # 显示 Docker 容器状态
    info "Docker 容器状态:"
    docker-compose -f docker-compose.prod.yml ps
}

# 显示使用说明
show_usage() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  docker      使用 Docker Compose 部署 (推荐)"
    echo "  vercel      部署前端到 Vercel"
    echo "  railway     部署后端到 Railway"
    echo "  cloud       准备云服务器部署"
    echo "  status      检查部署状态"
    echo "  all         完整部署 (Docker Compose)"
    echo ""
    echo "示例:"
    echo "  $0 docker    # 使用 Docker Compose 部署"
    echo "  $0 status    # 检查服务状态"
}

# 主函数
main() {
    local command=${1:-"all"}
    
    case $command in
        "docker")
            check_dependencies
            setup_environment
            deploy_docker_compose
            show_status
            ;;
        "vercel")
            deploy_vercel
            ;;
        "railway")
            deploy_railway
            ;;
        "cloud")
            check_dependencies
            deploy_cloud
            ;;
        "status")
            show_status
            ;;
        "all")
            check_dependencies
            setup_environment
            deploy_docker_compose
            show_status
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
    
    info "部署完成！"
    echo ""
    echo "🎉 您的 AI 小说工具箱商业化平台已部署成功！"
    echo ""
    echo "下一步操作："
    echo "1. 访问前端界面: http://localhost"
    echo "2. 测试 API 接口: curl http://localhost:3001/health"
    echo "3. 查看部署指南: cat 线上部署指南.md"
    echo "4. 配置支付渠道和域名"
    echo ""
    echo "祝您业务顺利！💰"
}

# 执行主函数
main "$@"
