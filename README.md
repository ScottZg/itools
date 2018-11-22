# Itools

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/itools`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation


```ruby
gem install itools
```

## Usage
```shell
$: itools

NAME
    itools - a collection of tools for ios developer

SYNOPSIS
    itools [global options] command [command options] [arguments...]

VERSION
    0.1.2

GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

COMMANDS
    help  - Shows a list of commands or help for one command
    parse - Analyze the memory footprint of each part or component in Xcode project

```

Demo
```shell
itools parse  LinkMapDemo-LinkMap-normal-arm64.txt  #link map file's name
# or
itools parse /user/Desk/LinkMapDemo-LinkMap-normal-arm64.txt
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/itools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Itools project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/itools/blob/master/CODE_OF_CONDUCT.md).
