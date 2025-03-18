# 安装python最新的镜像
FROM python:latest

# 安装pipx 和 poetry
RUN apt-get update && apt-get install -y pipx
RUN pipx ensurepath
# python自带的pip3指令
RUN pip3 install poetry

# 设置工作目录
WORKDIR /app

# 安装poetry依赖dependencies
COPY pyproject.toml ./
RUN pipx run poetry install --no-root

# 把本机的todo文件夹拷贝到container中
COPY todo todo

# 注意！entrypoint不会被覆盖，但是CMD命令会被覆盖override；所以一般来说CMD用于传递默认参数
# 控制台运行我们的程序application
CMD ["pipx","run","poetry","run","flask","--app","todo","run", \
"--host","0.0.0.0","--port","6400"]
