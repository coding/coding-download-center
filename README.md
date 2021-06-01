# CODING 下载中心

为中国开发者提供持续集成中常用的命令行软件下载，解决跨境下载缓慢的问题。

## 提交需要的软件

修改 `index.md`，加入需要的软件，发起合并请求，待管理员合并，会触发自动下载，并发布到公开制品库：

https://coding-public.coding.net/public-artifacts/public/downloads/packages

## 技术细节

提交代码会触发「CODING 持续集成（支持海外构建节点）」，自动执行 `coding-generic-sync.sh`：

-   解析 `index.md` 获取需要下载的软件列表
-   判断是否已存在于「CODING 制品库」，如不存在，则下载、校验、上传
