# itools

a iOSer's tool.

## Installation


```ruby
gem install itools
```

## Usage
### First Step
Open Xcode Write Link Map File Setting to YES for getting the Link Map File.
### Second Step
```shell
#link map file's name
itools parse  LinkMapDemo-LinkMap-normal-arm64.txt  
# or
itools parse /user/Desk/LinkMapDemo-LinkMap-normal-arm64.txt
```
The result is:
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
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ScottZg/itools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
