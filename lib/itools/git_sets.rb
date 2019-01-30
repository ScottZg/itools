require 'git'
module Itools
    class GitSets
        def self.commit_msg_init(args)
            puts "\033[32m开始配置...\033[0m"
            system('touch ./.git/commit_msg')
            system('git config commit.template "`pwd`/.git/commit_msg"')
            a = <<-EOF
#!/bin/sh
echo "$(git symbolic-ref --short HEAD) subject" > `pwd`/.git/commit_msg
echo "" >> `pwd`/.git/commit_msg
echo "Cause:" >> `pwd`/.git/commit_msg
echo "Solution:" >> `pwd`/.git/commit_msg
echo "Releated Doc Address:" >> `pwd`/.git/commit_msg
echo  '''\n#TYPE类型\n#新功能       feature\n#bug修复      bugfix\n#性能优化     perf\n#代码重构     refactor\n#线上修复     hotfix\n#发布版本     release\n#文档变更     docs''' >> `pwd`/.git/commit_msg
            EOF
            File.open('.git/hooks/pre-commit', 'w') do |f|
                f.puts a
            end
            logo_path = File.join( File.dirname(__FILE__), 'temple-commit-msg.dat' )
            content = File.read( logo_path )
            File.open('.git/hooks/commit-msg', 'w') do |f|
                f.puts content
            end
            system('chmod a+x .git/hooks/pre-commit')
            system('chmod a+x .git/hooks/commit-msg')
            puts "\033[32m配置成功，后续请直接使用git commit ,不要加 -m\033[0m"
        end
        # 生成changelog 
        def self.get_changelog(args)
            puts "生成changelog"
            g = Git.open(".")
            g.log.each {|gl|
                commit = g.gcommit(gl)
                puts commit.message

                break

            }
        end
    end
 end 