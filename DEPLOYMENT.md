# Paint Board 部署指南

## 🚀 快速测试

### 1. 本地开发测试

```bash
# 启动后端服务器
cd server
npm install
npm run dev

# 新开终端，启动前端
npm run dev
```

### 2. API测试

使用Postman或curl测试API：

```bash
# 测试注册
curl -X POST http://localhost:3001/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"123456"}'

# 测试登录
curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin7788","password":"abc123456"}'
```

## 📦 部署方案

### 方案一：简单部署（推荐）

```bash
# 运行部署脚本
chmod +x deploy-simple.sh
./deploy-simple.sh

# 启动服务
cd deploy
./start.sh
```

### 方案二：Docker部署

```bash
# 使用Docker Compose
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 方案三：云服务器部署

#### 1. 上传文件到服务器
```bash
# 使用scp上传
scp -r . user@your-server:/home/user/paint-board

# 或使用git
git clone your-repo
```

#### 2. 安装依赖并启动
```bash
# 安装Node.js (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装依赖
npm install
cd server && npm install && cd ..

# 启动服务
npm run build
cd server && npm start &
cd .. && npx serve -s dist -l 80
```

#### 3. 使用PM2管理进程
```bash
# 安装PM2
npm install -g pm2

# 启动后端
cd server
pm2 start index.js --name "paint-board-backend"

# 启动前端
cd ..
pm2 start "npx serve -s dist -l 80" --name "paint-board-frontend"

# 保存配置
pm2 save
pm2 startup
```

## 🔧 环境配置

### 环境变量

创建 `.env` 文件：

```env
# 前端环境变量
VITE_API_URL=http://your-server-ip:3001

# 后端环境变量
NODE_ENV=production
PORT=3001
JWT_SECRET=your-secret-key
```

### Nginx配置（可选）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态文件
    location / {
        root /var/www/paint-board/dist;
        try_files $uri $uri/ /index.html;
    }

    # 后端API代理
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📊 监控和维护

### 日志查看
```bash
# Docker日志
docker-compose logs -f

# PM2日志
pm2 logs

# 系统日志
journalctl -u your-service
```

### 数据库备份
```bash
# 备份SQLite数据库
cp server/users.db backup/users_$(date +%Y%m%d_%H%M%S).db
```

### 性能监控
```bash
# 查看进程状态
pm2 monit

# 查看系统资源
htop
```

## 🔒 安全建议

1. **修改JWT密钥**：在生产环境中修改 `JWT_SECRET`
2. **HTTPS配置**：使用SSL证书配置HTTPS
3. **防火墙设置**：只开放必要端口（80, 443, 3001）
4. **定期备份**：定期备份数据库文件
5. **日志监控**：设置日志监控和告警

## 🆘 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   lsof -i :3001
   # 杀死进程
   kill -9 <PID>
   ```

2. **数据库权限问题**
   ```bash
   # 修改数据库文件权限
   chmod 666 server/users.db
   ```

3. **CORS错误**
   - 检查后端CORS配置
   - 确认前端API地址正确

4. **内存不足**
   ```bash
   # 增加Node.js内存限制
   node --max-old-space-size=4096 index.js
   ``` 