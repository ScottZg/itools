require 'find'
module Itools
    class FileResult
        attr_accessor :keyword, :file_path, :file_name
        def initialize(temp_path,temp_name)
            @file_path = temp_path
            @file_name = temp_name
        end
    end
    class FileSearcher
        # path：搜索的路径，files要搜索的文件，支持数组用逗号隔开即可。支持模糊搜索
        attr_accessor :path ,:files, :search_result
        def initialize(temp_path,temp_files)
            @path = temp_path
            @files = temp_files
            @search_result = []
        end
        def search 
            puts @files
            if File::directory?(@path)
                Find.find(@path) do |file|
                    if File.file?(file)
                        file_name = File.basename(file)
                        if file_name.include?("ViewController.m")
                            fr = FileResult.new(file,file_name)
                            @search_result << fr
                        end
                        
                    end
                end
            else
                puts "\033[31m文件夹有误，请输入文件夹路径作为第一个参数\033[0m"
            end
        end
        # 对外暴露方法
        def self.searchFile(args)
            path = args[0]
            files = args[1]
            if path.nil? || files.nil? 
                puts "\033[31m参数异常，请传入两个参数，第一个为路径，第二个为要搜索的文件名\033[0m"
                return
            end
           temp_files = files.split(",")
            file_searcher = FileSearcher.new(path,temp_files)
            file_searcher.search
            # 输出
            puts "\033[32m找到共#{file_searcher.search_result.size}个文件结果如下；\033[0m"    
            file_searcher.search_result.each {|item| 
                puts item.file_name + "-----"+item.file_path
            }
            
        end
    end
end