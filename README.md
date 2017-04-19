# JBDownloadDemo

[具体说明见Blog](http://blog.csdn.net/goldwave01/article/details/70230239)

本demo运行环境在mac上，iOS也可以参考（除了UI部分其他均一样），使用系统自带的网络框架NSURLSession进行下载，NSURLSessionDataTask来进行下载数据，NSOperationQueue对数据写入硬盘。
实现了文件多线程并行下载，文件边下载边写入硬盘，断点续传（杀死APP后重启，可以继续上次未下载完的数据下载）

默认文件下载位置 (~/download)


![image](https://github.com/goldWave/JBDownloadDemo/blob/master/MyDownloadDemo/image.png)
