# freemem.sh
Free memory & cache on Linux system. 一键清理内存和 Cache 。

### 使用方法：

```bash
wget --no-check-certificate 'https://raw.githubusercontent.com/ernisn/freemem.sh/master/freemem.sh' && chmod +x freemem.sh && bash freemem.sh
```

**注意**：

1. 不支持 OpenVZ。

2. 该方法只在 cache 占用大量内存导致系统内存不够用时使用，当 buffer/cached 占用内存不大时用可能没什么效果。

![freemem5.0.png](https://i.loli.net/2019/01/11/5c3852ee597b5.png)

---

### 清理内容：

pagecache

- 页面缓存可以包含磁盘块的任何内存映射。这可以是缓冲 I/O，内存映射文件，可执行文件的分页区域——操作系统可以从文件保存在内存中的任何内容。Page cache 实际上是针对文件系统的，是文件的缓存，在文件层面上的数据会缓存到 page cache 。

dentries

- 表示目录的数据结构

inodes

- 表示文件的数据结构

---

更多解释可查看文章：[Linux 内存释放方法与简单分析](http://404guy.com/blog/20181107/linux-free-memory/)
