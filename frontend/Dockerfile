# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS builder

# Cài đặt gọn nhẹ
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Flutter SDK (stable)
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH="$PATH:/app/flutter/bin"

# Copy pubspec trước để cache dependency
COPY pubspec.* ./
RUN flutter pub get

# Copy toàn bộ source code
COPY . .

RUN flutter config --enable-web
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve bằng Nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
