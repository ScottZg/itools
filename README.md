# itools

一个方便iOS开发的工具类。主要是使用Ruby编写，用于进行一些方便的处理，例如字符串查找，LinkMap解析等。

## 安装


```ruby
gem install itools
```

## 使用
安装之后再终端执行itools，结果如下：
```shell
NAME
    itools - a collection of tools for ios developer

SYNOPSIS
    itools [global options] command [command options] [arguments...]

VERSION
    0.1.4

GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

COMMANDS
    help   - Shows a list of commands or help for one command
    parse  - Analyze the memory footprint of each part or component in Xcode project
    search - search str(or strs) in some file(or folder's file)
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
将会把number.txt中包含7的行输出，内容包括：文件名（这里是number.txt）、包含字符串（这里是7）、文件所在目录、查找内容所在行、查找结果  
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
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ScottZg/itools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
