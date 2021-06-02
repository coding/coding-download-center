# CODING 下载中心

[![CI](https://github.com/sinkcup/coding-download-center/actions/workflows/ci.yml/badge.svg)](https://github.com/sinkcup/coding-download-center/actions/workflows/ci.yml)
[![CODING 持续集成](https://coding-public.coding.net/badges/public/job/635809/main/build.svg)](https://e.coding.net/register?invite_register_token=8480c005dcae42a58ae5b2e89bf258a0)

为中国开发者提供持续集成中常用的命令行软件下载，解决跨境下载缓慢的问题。

## 提交需要的软件

修改 `index.md`，加入需要的软件（按照字母顺序），发起合并请求。

待管理员合并，会自动发布到内地的「CODING 制品库」：

https://coding-public.coding.net/public-artifacts/public/downloads/packages

## 技术细节

提交代码会触发「[CODING 持续集成（支持海外构建节点）](https://coding.net/products/ci)」，自动执行 `coding-generic-sync.sh`：

-   解析 `index.md` 获取需要下载的软件列表
-   判断是否已存在于「[CODING 制品库](https://coding.net/products/artifacts)」，如不存在，则下载、校验、上传
