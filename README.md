# Itools

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/itools`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/itools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Itools project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/itools/blob/master/CODE_OF_CONDUCT.md).
