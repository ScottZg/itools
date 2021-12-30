module Itools
    class PodInfo
        attr_accessor :pod_name, :pod_version
        def initialize(name,version)
            @pod_name = name
            @pod_version = version
        end
    end
    class PodfileTiled

        def self.podfile_tiled(args)

            all_pods = []  #所有依赖的pod
            exist_pods = [] #当前podfile已经存在的pod
            pod_tag = 1
        
            fileInfo = File.open(args[0])
            fileInfo.each_line{|line|
            line_string = line.delete("\n")
            if line_string == 'PODS:'
                puts '开始分析依赖'
                pod_tag = 1
                next
            elsif line_string == 'DEPENDENCIES:'
                pod_tag = 2
                next
            elsif line_string == 'SPEC REPOS:'
                pod_tag = 0
            end

            if pod_tag == 1  #分析所有pod
                if line_string[0,3]  == '  -' && !line_string.include?('/')
                    # puts line_string
                    pod_version = line_string[/\((.*?)\)/, 1]
                    pod_name = line_string.delete(pod_version).delete('(').delete(')').delete(':').delete('-').lstrip().rstrip
                    temp_pod =  PodInfo.new(pod_name,pod_version)
                    all_pods << temp_pod
                    # puts "pod #{pod_name}, '#{pod_version}'"
                end
            end
            if pod_tag == 2 #分析当前podfile已经有的pod
                
                    # puts line_string
                    pod_version = line_string[/\((.*?)\)/, 1]
                    if !pod_version
                        puts 'dd'
                    end
                    exit
                    pod_name = line_string.delete(pod_version).delete('(').delete(')').delete(':').delete('-').lstrip().rstrip
                    temp_pod =  PodInfo.new(pod_name,pod_version)
                    all_pods << temp_pod
                    puts "pod #{pod_name}, '#{pod_version}'"
            end
            }
        end
    end

end