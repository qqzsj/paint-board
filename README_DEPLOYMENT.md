# 绘画板项目部署指南

## 项目概述

这是一个基于React + Node.js的绘画板项目，支持多用户登录、图片上传和管理功能。项目采用Docker容器化部署，适合在Ubuntu服务器上运行。

## 功能特性

### 用户系统
- ✅ 用户注册/登录（最多30个设备用户）
- ✅ 管理员账户（admin/admin123）
- ✅ JWT认证和权限控制
- ✅ 用户管理后台

### 绘画功能
- ✅ 12种不同风格的画笔
- ✅ 形状绘制和文字功能
- ✅ 图层管理和对象操作
- ✅ 撤销/重做功能
- ✅ 画板配置和背景设置

### 图片管理
- ✅ 图片保存和下载
- ✅ 图片上传到服务器（10秒冷却时间）
- ✅ 管理员图片轮播展示
- ✅ 图片删除和管理

### AI功能
- ✅ 背景移除（需要WebGPU支持）
- ✅ 图像分割功能
- ✅ 智能图像处理

## 技术架构

```
前端 (React + TypeScript)
├── 绘画引擎: Fabric.js
├── UI框架: Tailwind CSS + DaisyUI
├── 状态管理: Zustand
└── 路由: React Router

后端 (Node.js + Express)
├── 数据库: SQLite
├── 认证: JWT + bcrypt
├── 文件上传: Multer
└── 安全: Helmet + CORS

部署 (Docker)
├── 前端: Nginx
├── 后端: Node.js Alpine
└── 网络: Docker Compose
```

## 快速部署

### 1. 环境要求
- Ubuntu 18.04+ 或 CentOS 7+
- Docker 20.10+
- Docker Compose 2.0+
- 至少2GB内存，10GB磁盘空间

### 2. 一键部署
```bash
# 克隆项目
git clone <your-repo-url>
cd paint-board-main

# 给部署脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

### 3. 手动部署
```bash
# 安装Docker（如果未安装）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 创建目录
mkdir -p server/uploads server/data dist

# 构建并启动
docker-compose up --build -d
```

## 服务访问

### 端口配置
- **8080**: 前端Web界面
- **3001**: 后端API服务（内部）

### 访问地址
- 前端: `http://your-server-ip:8080`
- API: `http://your-server-ip:8080/api`
- 健康检查: `http://your-server-ip:8080/api/health`

### 默认账户
- **管理员**: admin / admin123
- **普通用户**: 需要注册（最多30个）

## 使用说明

### 用户操作流程
1. 访问 `http://your-server-ip:8080`
2. 点击"注册"创建新账户
3. 登录后进入绘画界面
4. 使用各种工具进行绘画
5. 点击保存按钮选择下载或上传

### 管理员操作流程
1. 使用admin/admin123登录
2. 自动跳转到管理后台
3. 查看用户列表和统计信息
4. 管理图片和用户
5. 启动图片轮播展示

### 图片上传功能
- 点击保存按钮后选择"上传到服务器"
- 每次上传有10秒冷却时间
- 上传的图片会自动进入管理员轮播
- 管理员可以查看和删除所有图片

## 管理命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 更新服务
docker-compose up --build -d

# 清理数据
docker-compose down -v
rm -rf server/data/* server/uploads/*
```

## 数据备份

### 数据库备份
```bash
# 备份SQLite数据库
cp server/data/paintboard.db backup_paintboard_$(date +%Y%m%d).db
```

### 图片备份
```bash
# 备份上传的图片
tar -czf images_backup_$(date +%Y%m%d).tar.gz server/uploads/
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :8080
   # 修改docker-compose.yml中的端口映射
   ```

2. **权限问题**
   ```bash
   # 修复目录权限
   sudo chown -R $USER:$USER server/uploads server/data
   sudo chmod -R 755 server/uploads server/data
   ```

3. **服务启动失败**
   ```bash
   # 查看详细日志
   docker-compose logs backend
   docker-compose logs nginx
   ```

4. **数据库问题**
   ```bash
   # 重置数据库
   rm -f server/data/paintboard.db
   docker-compose restart backend
   ```

### 性能优化

1. **增加内存限制**
   ```yaml
   # 在docker-compose.yml中添加
   services:
     backend:
       deploy:
         resources:
           limits:
             memory: 1G
   ```

2. **启用缓存**
   ```bash
   # 在nginx.conf中已配置静态文件缓存
   # 图片文件缓存1天，静态资源缓存1年
   ```

## 安全建议

1. **修改默认密码**
   - 首次登录后立即修改管理员密码
   - 定期更换密码

2. **防火墙配置**
   ```bash
   # 只开放必要端口
   sudo ufw allow 8080
   sudo ufw enable
   ```

3. **SSL证书**
   ```bash
   # 配置HTTPS（推荐）
   # 可以使用Let's Encrypt免费证书
   ```

## 开发说明

### 本地开发
```bash
# 前端开发
npm install
npm run dev

# 后端开发
cd server
npm install
npm run dev
```

### API文档
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/admin/users` - 获取用户列表
- `GET /api/admin/images` - 获取图片列表
- `POST /api/upload` - 上传图片

## 许可证

MIT License - 详见 LICENSE 文件

## 支持

如有问题，请提交Issue或联系开发团队。
