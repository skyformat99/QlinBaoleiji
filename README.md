=麒麟堡垒机安装分为ISO安装、安装包、云镜像安装三种方式：


-安装方式一. ISO 系统安装（适用硬件、VM）：

官网下载地址：
http://get.tosec.com.cn/open.iso
百度网盘地址:
http://pan.baidu.com/s/1mhSAmUG

安装条件：系统必须至少有一块网卡，系统硬件为：Intel 64位CPU、2G内存（建议4G）、硬盘80G以上。

如果用VM安装，必须使用IDE硬盘并且使用64位类型虚机，如果用SCSI硬盘会安装不，版本如果不选择64bit安装后会无法启动网卡。
安装过程为使用cdrom启动，启动后到一个菜单，在默认的GPT上回车，即可完成，安装过程大约需要20分钟


-安装方式二. 安装包安装方式（适用无法使用光驱的硬件或VM）：

官网下载地址:
http://get.tosec.com.cn/centos7.tar.gz
百度云下载地址：
http://pan.baidu.com/s/1miKcWmG

系统安装: 安装MINI Centos7.x 或使用云模版最小化Centos 7.X
安装包安装过程：
mkdir /tmp/test/soft
将centos7.tar.gz 上传到系统/tmp/test/soft目录

cd /tmp/test/soft

tar xpvf  centos7.tar.gz

运行以下命令进行rpm包下载

bash yum.sh （非阿里云系统必须配置好DNS并且连到互联网才能运行成功，如果未连接互联网请自己设置本地源安装，阿里云有自己的源可以直接运行安装）

bash install.sh

注意，安装完成后必须要重启系统，否则无法开启堡垒机服务。



-安装方式四. 阿里云、华为云镜像安装：

阿里云镜像地址：
https://market.aliyun.com/products/56848019/cmjj021886.html?spm=5176.730005.0.0.9Z0mzT

华为云镜像地址：
https://app.huaweicloud.com/product/00301-47088-0--0


使用文档：

 管理员使用步骤:
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=36
 
 运维人员使用手册：
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=4&extra=page%3D1
 
 动态口令使用手册:
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=7&extra=page%3D1
 
 SSL VPN使用手册：
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=5&extra=page%3D1
 
 审计回放手册:
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=25&extra=page%3D1
 
 苹果MacOS使用手册:
 http://www.tosec.com.cn/forum.php?mod=viewthread&tid=31&extra=page%3D1
 
 
 
 
 
 
 






