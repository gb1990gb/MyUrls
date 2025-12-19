# 第一阶段：构建
FROM golang:1.24-alpine AS build

WORKDIR /app

# 优化点 1: 先拷贝依赖文件，单独下载依赖
# 只有当 go.mod 或 go.sum 改变时，这部分才会重新执行
COPY go.mod go.sum ./
RUN go mod download

# 优化点 2: 再拷贝源代码（此时依赖已在缓存层）
COPY . .

# 编译
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o myurls

# 第二阶段：运行
FROM scratch
WORKDIR /app
COPY --from=build /app/myurls ./
# 优化点 3: 只有 public 下的内容改变才会触发布建
COPY public/ ./public/

EXPOSE 8080
ENTRYPOINT ["/app/myurls"]
