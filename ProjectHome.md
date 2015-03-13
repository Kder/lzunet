兰大上网认证系统跨平台自动登录工具。可以实现一键登录/一键下线，无需打开浏览器，无需再手动输入邮箱和密码。

## 基本用法 ##
> Windows 和 Linux 用户分别运行下列文件即可(首次运行时会提示输入账号信息)。
    * 登录：登录.bat 或 login.sh
    * 下线：下线.bat 或 logout.sh

> 如果提示信息无法显示（例如在Linux终端下中文可能会乱码），可手动把lzunet.ini中的userid和password等号后的test分别替换为你上网认证的账号和密码，保存，然后再运行上述对应的文件。

## 下载 ##
> 【注意】 由于最近认证系统再次更换，经常出现连接不上的情况。如果出现“发生错误，请检查网络连接是否正常”的提示：
  1. 首先看看是否网线没接好或者网络连接受限
  1. 有可能是认证系统的问题，不必管它，应该就可以直接上外网了

  * Windows版（一般用户请下载这个）：
> http://lzunet.googlecode.com/files/lzunet-1.4.0.121-win.7z

  * 源代码版（Linux或者其他系统用户）：
> http://lzunet.googlecode.com/files/lzunet-1.4.0.123-src.7z

> 源码版系统要求 http://code.google.com/p/lzunet/wiki/SystemRequirements