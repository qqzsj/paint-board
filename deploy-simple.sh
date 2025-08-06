#!/bin/bash

# 简单部署脚本 - 适用于单服务器部署

echo "开始部署 Paint Board 项目..."

# 1. 构建前端
echo "构建前端..."
npm run build

# 2. 安装后端依赖
echo "安装后端依赖..."
cd server
npm install
cd ..

# 3. 创建部署目录
echo "创建部署目录..."
mkdir -p deploy
cp -r dist/* deploy/
cp -r server deploy/
cp package.json deploy/

# 4. 创建启动脚本
cat > deploy/start.sh << 'EOF'
#!/bin/bash

# 启动后端服务器
cd server
npm start &
BACKEND_PID=$!

# 启动前端服务器（使用简单的HTTP服务器）
cd ..
npx serve -s . -l 8080 &
FRONTEND_PID=$!

echo "后端服务器 PID: $BACKEND_PID"
echo "前端服务器 PID: $FRONTEND_PID"
echo "前端访问地址: http://localhost:8080"
echo "后端API地址: http://localhost:3001"

# 等待进程结束
wait
EOF

chmod +x deploy/start.sh

echo "部署完成！"
echo "进入 deploy 目录运行 ./start.sh 启动服务" 