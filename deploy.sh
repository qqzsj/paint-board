#!/bin/bash

# 绘画板项目部署脚本
# 适用于Ubuntu服务器

set -e

echo "🎨 开始部署绘画板项目..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，正在安装Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "✅ Docker安装完成，请重新登录后运行此脚本"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，正在安装..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose安装完成"
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p server/uploads
mkdir -p server/data
mkdir -p dist

# 设置目录权限
echo "🔐 设置目录权限..."
sudo chown -R $USER:$USER server/uploads
sudo chown -R $USER:$USER server/data
sudo chmod -R 755 server/uploads
sudo chmod -R 755 server/data

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose down --remove-orphans || true

# 构建并启动服务
echo "🔨 构建并启动服务..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 检查健康状态
echo "🏥 检查服务健康状态..."
if curl -f http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ 后端服务健康检查通过"
else
    echo "❌ 后端服务健康检查失败"
    docker-compose logs backend
    exit 1
fi

if curl -f http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ 前端服务健康检查通过"
else
    echo "❌ 前端服务健康检查失败"
    docker-compose logs nginx
    exit 1
fi

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 服务信息："
echo "   🌐 前端地址: http://localhost:8080"
echo "   🔧 后端API: http://localhost:8080/api"
echo "   📊 健康检查: http://localhost:8080/api/health"
echo ""
echo "👤 默认管理员账户："
echo "   用户名: admin"
echo "   密码: admin123"
echo ""
echo "📝 使用说明："
echo "   1. 访问 http://localhost:8080 进入登录页面"
echo "   2. 管理员登录后会自动跳转到管理后台"
echo "   3. 普通用户登录后可以开始绘画"
echo "   4. 最多支持30个用户设备注册"
echo ""
echo "🔧 管理命令："
echo "   查看日志: docker-compose logs -f"
echo "   停止服务: docker-compose down"
echo "   重启服务: docker-compose restart"
echo "   更新服务: docker-compose up --build -d"
echo ""
