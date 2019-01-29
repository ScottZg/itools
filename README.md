# itools

一个方便iOS开发的工具类。主要是使用Ruby编写，用于进行一些方便的处理，例如字符串查找，LinkMap解析等。  
## 安装


```ruby
gem install itools
```
## 说明
该命令执行的时间与文件夹的大小以及文件多少有关。所以如果有执行停留问题，请耐心等待。
## 使用
安装之后再终端执行itools，结果如下：
```shell
NAME
    itools - a collection of tools for ios developer

SYNOPSIS
    itools [global options] command [command options] [arguments...]

VERSION
    0.4.9

GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

COMMANDS
    count_code_line    - 统计代码行数
    find               - 查找无用图片
    parse              - 解析linkmap
    pre_commit         - 通过执行该命令，hook 本地commit，然后进行规范化
    search             - 在文件夹或文件中查找字符串（或者字符串组）
    search_file        - 查找文件
    search_unuse_class - 查找无用类
    size_for           - 计算文件或者文件夹占用内存大小
```

### 功能1：解析LinkMap
命令：
```shell
itools parse  LinkMapDemo-LinkMap-normal-arm64.txt  
# or
itools parse /user/Desk/LinkMapDemo-LinkMap-normal-arm64.txt
```
解析结果实例:
```ruby
AppDelegate.o          8.50KB
ViewController.o          735B
LinkMapDemo.app-Simulated.xcent          386B
main.o          192B
 linker synthesized          128B
libobjc.tbd          120B
Foundation.tbd          24B
UIKit.tbd          24B
Total Size：10.07KB
```
For more information, see：[https://www.cnblogs.com/zhanggui/p/9991455.html](https://www.cnblogs.com/zhanggui/p/9991455.html)

### 功能2：字符串查找
命令
```ruby
itools search folder/file str/strs
```
例如：  
1.单字符查找：查找number.txt中包含7的行  
```ruby 
itools search number.txt 7
```
将会把number.txt中包含7的行输出，内容包括：文件名（这里是number.txt）、包含字符串（这里是7）、文件所在目录、查找内容所在行、查找结果。    
2.多字符查找：查找number.txt中包含7，8的行  
```ruby
itools search number.txt 7,8
```
将会把number.txt中包含7、8的行记录到excel表中，表内容和上面的展示一样。  
3.在文件夹所有文件中查找某个字符串：  
```ruby
itools search /Users/zhanggui/zhanggui/my-dev MAYGO
```
将会把/Users/zhanggui/zhanggui/my-dev文件夹中所有的文件进行遍历，然后找到包含MAYGO字符串的类，并生成excel文件。  
4.在文件夹所有文件文件中查找某些字符串：
```ruby
itools search /Users/zhanggui/zhanggui/Ruby/ 3434,Scott
```
将会在/Users/zhanggui/zhanggui/Ruby/中查找所有包含3434和Scott的文件，并生成excel。

### 功能3：查找工程中无用的图片
命令   
```
itools find /Users/zhanggui/zhanggui/tdp
```
这里的目录代表项目的根目录，查找原理为：    
先将目录下面所有的图片（仅支持png、jpg、gif）找到，然后遍历所有.m文件。查找出没有使用的图片。   
**注：这里查找不太准确，仅供参考，因为有可能有的图片不是通过.m文件使用的。而有的图片仅仅是为了配置（例如1024*1024），所以还是不要依赖该工具的图片查找，找到之后可以自行再次确认一下。**

### 功能4：计算文件大小
命令
```
itools size_for /Users/zhanggui/zhanggui/my 1000
or
 itools size_for /Users/zhanggui/zhanggui/my 
```
计算sizeFor后面跟的参数内容所占内存大小，如果参数为文件路径，则计算文件大小，如果是文件夹，会遍历所有文件，然后计算大小。第二个参数为计算系数（这个系数为1MB = 1024KB中的1024；windows为1024，mac为1000，不传默认为1024）。  
在中途会提示你输入要查找的文件后缀，不输入任何则表示查找文件夹下的所有文件，输入后缀则会计算特定文件类型包含的大小，例如：png,jpg,gif，这样会计算出文件夹中三种类型格式的图片所占有内存的大小。

### 功能5：查找文件
命令
```
itools search_file /Users/zhanggui/zhanggui/my-dev/search_vc  ViewController.m   #第二个参数现在只支持单字符串查找
```
查找/Users/zhanggui/zhanggui/my-dev/search_vc文件夹下所有的文件名包含ViewController.m的文件，并且输出到excel表格    

### 功能6：查找工程中无用的文件
命令
```
itools search_unuse_class /Users/zhanggui/zhanggui/my-dev/search_vc
```
参数为工程所在的文件夹，例如/Users/zhanggui/zhanggui/my-dev/search_vc。查出的结果可能包含category或者extension，请拿结果作为参考，不作为最终要删除的文件。

### 功能7：统计代码行数
命令
```
itools count_code_line 文件路径/文件夹路径
#例如
itools count_code_line /User/zhanggui/mydemoapp  #统计mydemoapp项目的代码行数
```
该工具只统计了.m、.mm、.h、.cpp这几个文件，并且不包含单行注释以及空行。
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ScottZg/itools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 

## FBI Warning
如有误删而导致的线上问题，本人概不负责！
