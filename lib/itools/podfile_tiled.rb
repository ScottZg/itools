module Itools
    class PodInfo
      attr_accessor :pod_name, :pod_version
      def initialize(name, version)
        @pod_name = name
        @pod_version = version
      end
    end
    class PodfileTiled
      def self.podfile_tiled(args)
        all_pods = [] #所有依赖的pod
        exist_pods = [] #当前podfile已经存在的pod
        need_add_pods = [] #当前需要添加到podfile中的pod
        pod_tag = 1
  
        fileInfo = File.open(args[0])

        total_index = 0
        fileInfo.each_line do |line|
          line_string = line.delete("\n")
          if line_string == 'PODS:'
            # 配置成功，后续请直接使用git commit ,不要加 -m\033[0m
            puts "\033[32m开始分析依赖\033[0m"
            pod_tag = 1
            next
          elsif line_string == 'DEPENDENCIES:'
            puts "\033[32m开始分析当前Podfile中已添加的依赖项\033[0m"
            pod_tag = 2
            next
          elsif line_string == 'SPEC REPOS:'
            pod_tag = 0
            puts "\033[32mpodfile.lock分析结束\033[0m"
          end
  
          if pod_tag == 1 #分析所有pod
            if line_string[0, 3] == '  -' && !line_string.include?('/')
              # puts line_string
              pod_version = line_string[/\((.*?)\)/, 1]
              pod_name =
                line_string.gsub(pod_version, '').delete('(').delete(')').delete(
                  ':'
                ).delete('-').strip
              temp_pod = PodInfo.new(pod_name, pod_version)
              all_pods << temp_pod
              puts "查找到pod库：#{pod_name}, 版本号为：'#{pod_version}' #{all_pods.length}"
            end
          end
  
          if pod_tag == 2 #分析当前podfile已经有的pod
            pod_name
            pod_version = line_string[/\((.*?)\)/, 1]
            if pod_version
              pod_name =
                line_string.gsub(pod_version, '').delete('(').delete(')').delete(
                  ':'
                ).delete('-').strip
            else
              pod_name = line_string.delete('-').lstrip.rstrip
            end
            # if pod_name.length == 0 || pod_name.include?('/')
            #     next
            # end
            temp_pod = PodInfo.new(pod_name, pod_version)
            if pod_version
                temp_pod.pod_version = pod_version.delete('=').strip 
            end
           
            exist_pods << temp_pod 
            puts "Podfile中已包含 #{pod_name}, 版本号为：'#{pod_version}'"
          end
        end
        temp_exist_pods = []
        all_pods.each do |all_pod|
          exist_pods.each do |exist_pod|
            exist_pod_name = exist_pod.pod_name
            if exist_pod_name.include?('/')
              exist_pod_name = exist_pod_name.split('/')[0]
            end
            if all_pod.pod_name == exist_pod_name
              temp_exist_pods << all_pod
            end
          end
        end

        need_add_pods = all_pods - temp_exist_pods
        if need_add_pods.length == 0
            puts "\033[32m恭喜！！！无需平铺，当前已全部平铺\033[0m"
        else
            puts "\033[32m以下为要平铺的库，直接复制粘贴至Podfile中即可：\033[0m"
            need_add_pods.each do |to_add|
                puts "pod '#{to_add.pod_name}', '#{to_add.pod_version}'"
            end
        end
     
      end
    end
  end
  