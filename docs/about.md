gmirror 本意是 google mirror，用于提供国外优秀资源的国内镜像。

包含下列项目：

 * gmirror
 * gmirror-fonts

## gmirror

这是一个下载和上传工具。代码为几个shell和markdown文件，放在github上，通过travis-ci.org持续集成自动下载国外的文件，并生成文件列表页面，一起上传到七牛云存储上。

线上效果：[http://gmirror.org/](http://gmirror.org/) 和 [http://dl.gmirror.org/](http://dl.gmirror.org/)

代码：[https://github.com/sinkcup/gmirror](https://github.com/sinkcup/gmirror)

协作方式：Fork，更新`dl/origin.md`中的软件版本，发起Pull request即可。如果是新增软件，则还要修改`docs/index.tpl.md`。

## gmirror-fonts

这是字体镜像网站，支持http和https。使用PHP lumen框架，放在github上，通过daocloud.io持续集成自动构建docker镜像，部署到容器中，无需服务器。

用户请求 https://fonts.gmirror.org/css 时，PHP去获取 https://fonts.googleapis.com/css 对应的内容，把其中的 fonts.gstatic.com 替换为 fonts-gstatic-com.gmirror.org（七牛），css缓存在后端服务器上，字体文件通过七牛自动拉取。

线上效果：[https://fonts.gmirror.org/](https://fonts.gmirror.org/)

代码：[https://github.com/sinkcup/gmirror-fonts](https://github.com/sinkcup/gmirror-fonts)

## 为开源做贡献

 * 加入开源项目，一起写代码吧。
 * 通过本站邀请链接注册[七牛云储存](https://portal.qiniu.com/signup?code=3lafkpsz7yes1)，本站将获得5GB/人的流量奖励，供大家下载使用。

## 感谢

 * 感谢 [七牛云储存](https://portal.qiniu.com/signup?code=3lafkpsz7yes1) 的 [开源扶持计划](http://hd.qiniu.com/supportopen/) 提供每月5TB免费下载流量。
