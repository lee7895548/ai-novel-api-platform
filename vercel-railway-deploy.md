# AI 小说工具箱 - Vercel + Railway 部署指南

## 🚀 快速部署方案一：Vercel + Railway

### 总览
- **前端**: Vercel (免费额度充足)
- **后端**: Railway (起步 $5/月)
- **数据库**: Railway PostgreSQL (免费额度)
- **总成本**: $5-20/月
- **部署时间**: 10-15分钟

## 📋 部署前准备

### 1. 账户注册
- [ ] 注册 [Vercel](https://vercel.com) 账户
- [ ] 注册 [Railway](https://railway.app) 账户
- [ ] 注册 [GitHub](https://github.com) 账户 (如果还没有)

### 2. 代码准备
- [ ] 将代码推送到 GitHub 仓库
- [ ] 准备好 DeepSeek API 密钥

## 🛠️ 详细部署步骤

### 步骤 1: 部署前端到 Vercel

#### 方法 A: 通过 GitHub 自动部署 (推荐)
1. 登录 [Vercel](https://vercel.com)
2. 点击 "New Project"
3. 选择您的 GitHub 仓库
4. 配置项目设置：
   - **Framework Preset**: Vite
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`

5. 配置环境变量：
   ```
   VITE_API_URL=https://your-backend-domain.railway.app
   ```

6. 点击 "Deploy"

#### 方法 B: 使用 Vercel CLI
```bash
# 安装 Vercel CLI
npm install -g vercel

# 登录
vercel login

# 在 frontend 目录部署
cd frontend
vercel --prod
```

### 步骤 2: 部署后端到 Railway

#### 方法 A: 通过 GitHub 自动部署
1. 登录 [Railway](https://railway.app)
2. 点击 "New Project"
3. 选择 "Deploy from GitHub repo"
4. 选择您的仓库
5. Railway 会自动检测 Node.js 项目

#### 方法 B: 使用 Railway CLI
```bash
# 安装 Railway CLI
npm install -g @railway/cli

# 登录
railway login

# 在项目根目录初始化
railway init

# 部署
railway deploy
```

### 步骤 3: 配置 Railway 环境变量

在 Railway 项目设置中配置以下环境变量：

```bash
# 必需配置
NODE_ENV=production
PORT=3001
DEEPSEEK_API_KEY=您的DeepSeek_API密钥
JWT_SECRET=生成一个随机的JWT密钥（可以使用 openssl rand -hex 32）

# 数据库配置（Railway 自动提供）
DATABASE_URL=自动提供

# 业务配置
FREE_TIER_WORD_LIMIT=1000
FREE_TIER_API_LIMIT=100
COST_PER_WORD=0.0001
```

### 步骤 4: 配置数据库

1. 在 Railway 项目中添加 PostgreSQL 插件
2. Railway 会自动提供 `DATABASE_URL` 环境变量
3. 应用会自动创建所需的表结构

### 步骤 5: 获取后端域名并更新前端

1. 部署完成后，Railway 会提供一个域名，如：`https://your-app.railway.app`
2. 在 Vercel 中更新前端环境变量：
   ```
   VITE_API_URL=https://your-app.railway.app
   ```
3. 重新部署前端

## 🔧 配置文件说明

### Vercel 配置 (vercel.json)
```json
{
  "version": 2,
  "builds": [
    {
      "src": "frontend/package.json",
      "use": "@vercel/static-build",
      "config": { "distDir": "dist" }
    }
  ],
  "routes": [
    { "src": "/(.*)", "dest": "/frontend/$1" }
  ]
}
```

### Railway 配置 (railway.toml)
```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "npm start"

[env]
NODE_ENV = "production"
PORT = "3001"
DATABASE_TYPE = "postgres"
```

## 🌐 域名配置 (可选)

### 自定义域名 - Vercel
1. 在 Vercel 项目设置中添加自定义域名
2. 在域名服务商处配置 CNAME 记录
3. Vercel 自动提供 SSL 证书

### 自定义域名 - Railway
1. 升级到 Railway Pro 计划 ($20/月)
2. 在项目设置中配置自定义域名
3. 或使用 Cloudflare 进行反向代理

## 📊 成本估算

### 免费额度
- **Vercel**: 100GB 带宽/月，无限网站
- **Railway**: $5 免费额度/月
- **PostgreSQL**: 1GB 存储，共享 CPU

### 预计月度成本
- **小规模使用**: $5-10/月
- **中等规模**: $10-20/月  
- **大规模**: $20-50/月

## 🛡️ 安全配置

### 环境变量安全
- 不要在代码中硬编码敏感信息
- 使用 Railway 和 Vercel 的环境变量管理
- 定期轮换 API 密钥

### CORS 配置
后端已配置允许 Vercel 域名的 CORS：
```javascript
app.use(cors({
  origin: [
    'https://your-frontend.vercel.app',
    'http://localhost:3000'
  ]
}));
```

## 🔍 部署后检查

### 健康检查
```bash
# 检查后端服务
curl https://your-app.railway.app/health

# 应该返回：
{"status":"OK","timestamp":"...","version":"1.0.0"}
```

### 功能测试
1. 访问前端域名
2. 测试用户注册/登录
3. 测试小说生成功能
4. 检查计费系统

## 🚨 故障排除

### 常见问题

#### 前端无法连接后端
- 检查 `VITE_API_URL` 环境变量
- 确认后端服务正在运行
- 检查 CORS 配置

#### 数据库连接失败
- 确认 `DATABASE_URL` 环境变量正确
- 检查 PostgreSQL 插件状态
- 查看 Railway 日志

#### 构建失败
- 检查 `package.json` 中的依赖
- 确认构建命令正确
- 查看构建日志

### 查看日志
```bash
# Vercel 日志
vercel logs

# Railway 日志  
railway logs
```

## 📈 性能优化

### 前端优化
- 启用 Vercel 的 CDN 缓存
- 优化图片和静态资源
- 使用代码分割

### 后端优化
- 启用 Railway 的自动扩缩容
- 使用连接池
- 启用查询缓存

## 🔄 持续部署

### 自动部署设置
1. 在 GitHub 中启用 Actions
2. 配置自动测试
3. 设置自动部署到 staging 环境
4. 手动批准生产部署

### 环境分离
- **开发**: 本地环境
- **Staging**: Railway Staging 环境  
- **生产**: Railway Production 环境

## 💰 商业化就绪

### 支付集成
1. 配置 Stripe、支付宝或微信支付
2. 在环境变量中添加支付密钥
3. 测试支付流程

### 监控和分析
1. 集成 Google Analytics
2. 设置错误监控 (Sentry)
3. 配置业务指标监控

---

## 🎯 立即开始部署！

### 快速检查清单
- [ ] GitHub 仓库准备就绪
- [ ] Vercel 和 Railway 账户注册
- [ ] DeepSeek API 密钥准备
- [ ] 按照上述步骤部署
- [ ] 测试所有功能
- [ ] 配置自定义域名 (可选)
- [ ] 设置监控和告警

### 预计时间
- **初次部署**: 15-30分钟
- **功能测试**: 10分钟  
- **域名配置**: 5-10分钟

**您的 AI 小说工具箱商业化平台将在 30 分钟内上线运行！🚀**
