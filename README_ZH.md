# CSSE6400 Week 3 Practical
这是CSSE6400这门课的中文说明文档，具体的项目笔记可以参考这里
#### 项目结构

```bash
2025-P3-WITHOUTBUG8/
│── .csse6400/             # 课程相关的配置文件
│── .github/               # GitHub Actions 相关的配置
│── .idea/                 
│── data/                  # 数据存储目录，可能用于持久化数据库
│── tests/                 # 单元测试文件夹
│   ├── base.py            # 可能是测试的基类或测试初始化
│   ├── test_health.py     # 用于测试 API（'api/v1/health'）
│   ├── test_todo.py       # 自动化测试（每次修改代码以后，快速检查API是否正常工作）
│── todo/                  
│   ├── models
│   		├── _init_.py      # 初始化数据库对象，用于整个数据库操作
│   		├── todo.py        # 定义数据库表的模型，提供数据库交互的方法
│   ├── views
│   		├── routes.py      # 路由，处理todo相关的HTTP请求，并和数据库交互
│   ├── _init_.py				 # 全部应用的初始化文件，初始化并配置flask应用，初始化数据库，配置路由生效
│── .dockerignore          # Docker 构建时忽略的文件
│── docker-compose.yml     # Docker Compose 配置文件（定义数据库和应用容器）
│── Dockerfile             # 用于构建 Flask 应用的 Docker 镜像
│── endpoints.http         # API测试文件，借助于REST Client插件
│── pyproject.toml         # Python 依赖管理（使用 Poetry）
│── README_ZH.md           # 中文版 README，说明项目用途和使用方法
│── README.md              # 项目说明文件
```

#### 工作原理（项目运行流程）

1. Docker启动服务
   - Docker Compose启动以后项目通过docker-compose.yml运行，
     - 启动两个服务
       1. PostgreSQL数据库
       2. Flask API服务器
2. Flask处理API请求
   - 当客户端发送HTTP请求，Flask会使用route.py解析请求，调用models/todo.py查询数据库，将查询结果转换为json之后返回HTTP响应
3. 数据库交互
   - SQLAlchemy负责管理数据库的操作，与PostgreSQL交互
4. 返回API响应
   - 有todo/views/routes.py负责API响应，返回JSON给客户端
5. 测试API
   1. 通过endpoint.http进行某一个API的测试
   2. 通过tests/test_todo.py进行自动化测试检测API是否正常的工作

#### 具体问题解释

1. 为什么我启动了Docker中的Flask和PostgreSQL这两个服务，我可以通过本机的endpoint.http对容器中的代码进行测试呢？

   - 首先endpoint.http文件发送请求指向http://localhost:6400；与此同时Docker的docker-compose.yml文件中配置ports: - "6400:6400" **让容器内部的 6400 端口映射到本机的 6400 端口**

     ```python
     '''
     1. 在Dockerfile中配置了端口: 
     		--host 0.0.0.0 → 监听所有 IP，允许外部访问； 
     		--port 6400 → 运行在端口 6400
     一句话概括容器内部监听0.0.0.0:6400
     '''
     CMD ["pipx","run","poetry","run","flask","--app","todo","run", \
     "--host","0.0.0.0","--port","6400"]
     
     '''
     2. 在docker-compose.yml文件里: 
     把6400端口映射到主机6400端口
     '''
     app:
       ports:
         - "6400:6400"
     
     '''
     3. 最后在endpoint.http文件中请求指向6400端口
     '''
     @baseUrl = http://localhost:6400
     ```

2. 具体的一些细节说明：

   - .dockerignore 这个文件是用于忽略不必要的文件，避免被复制到Docker镜像中。具体来说：可以防止敏感信息如密钥等泄漏，防止被意外打包进镜像。

   - dockerfile文件中: 上课时候讲的**entrypoint不会被覆盖，但是CMD命令会被覆盖override**；所以一般来说CMD用于传递默认参数

     ```bash
     FROM ubuntu:latest
     CMD ["echo", "Hello, World!"]
     # 如果在此时运行其他的CMD，也许会造成指令覆盖，假设运行新的CMD后
     docker run myimage echo "Hi!"
     # 输出结果就是Hi
     FROM ubuntu:latest
     ENTRYPOINT ["echo", "Hello,"]
     # 如果运行这个始终输出Hello
     ```

     

