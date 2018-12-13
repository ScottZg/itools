require 'find'
require 'spreadsheet'
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
            puts "\033[32m开始查找...\033[0m"    
            if File::directory?(@path)
                Find.find(@path) do |file|
                    if File.file?(file)
                        file_name = File.basename(file)
                        if file_name.include?(@files)
                            fr = FileResult.new(file,file_name)
                            @search_result << fr
                        end
                    else
                        # puts "查找#{file}..."
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
        #    temp_files = files.split(",")
            file_searcher = FileSearcher.new(path,files)
            file_searcher.search
            if file_searcher.search_result.size == 0
                puts "\033[32m没有找到符合条件的文件\033[0m"    
                return
            end
            # 输出
              # 输出搜索的内容
        
              Spreadsheet.client_encoding = 'utf-8'
              book = Spreadsheet::Workbook.new
              sheet1 = book.create_worksheet
              sheet1.row(0)[0] = "序号"
              sheet1.row(0)[1] = "文件名"
              sheet1.row(0)[2] = "文件所在路径"
              
            
              puts "\033[32m找到共#{file_searcher.search_result.size}个文件结果如下；\033[0m"    
              file_searcher.search_result.each_with_index {|item,i| 
                puts item.file_name
                sheet1.row(i+1)[0] = i + 1
                sheet1.row(i+1)[1] = item.file_name
                sheet1.row(i+1)[2] = item.file_path
                sheet1.row(i+1).height = 20
            } 
            sheet1.column(0).width = 4
            sheet1.column(1).width = 45
            sheet1.column(2).width = 100
            book.write "#{File.dirname(path)}/search_#{files}_result.xls"
            puts "\033[32m查找成功,共#{file_searcher.search_result.size}个文件,内容已经保存到#{File.dirname(path)}/search_#{files}_result.xls，请点击查看\033[0m"
        end
    end
end