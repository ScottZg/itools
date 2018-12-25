require 'find'
module Itools
    class ClassFinder
        attr_accessor :search_path, :classes, :search_in_files
        def initialize(temp_search_path)
            @search_path = temp_search_path
            @classes = []
            @search_in_files = []
        end
        def search
            # 找到所有的.h以及所有要查找的文件
            Find.find(@search_path) do |path|
                if File.file?(path)
                    if !get_not_contain_file_ext.include?(File.extname(path))
                        @search_in_files << path    
                    end
                    
                    if File.extname(path).eql?(".h")
                        ff_result = FindResult.new(File.basename(path,".h"),path)
                        @classes << ff_result
                    end
                end
            end

            # 删除使用的文件
            use_idxs = Set.new
            @search_in_files.each{|s_file|
                s_containet = ""
                File.read(s_file).each_line do |line|
                    s_containet << line
                    s_containet << ","
                 end
                # 查找所有文件在单个文件中是否被引用
                 @classes.each_with_index{|f_result,idx|
                    search_file_no_ext =  get_no_ext_path(s_file)
                    check_file_no_ext = get_no_ext_path(f_result.fr_path)
                    # 判断是否是同一个文件或者是通文件的.m/.h,不是同一个文件才查找
                    if !check_file_no_ext.eql?(search_file_no_ext)
                        inheritance_str = ": #{f_result.fr_name}"
                        contain_str = '@"' + f_result.fr_name + '"'
                        reference_str = "#{f_result.fr_name}.h"
                        
                        # if s_containet.match(/: #{f_result.fr_name}|@"#{f_result.fr_name}"|#{f_result.fr_name}.h/) != nil
                        if s_containet.include?(inheritance_str) or s_containet.include?(contain_str) or s_containet.include?(reference_str)
                            use_idxs << f_result
                            puts "#{f_result.fr_name}已使用，剩余查找文件数#{@classes.size - use_idxs.size}..."    
                        end
                    end 
                }

            }
            final_result = []
         
            temp_final_result_str = ''
            use_idxs.to_a.each {|u_x|
                temp_final_result_str << u_x.fr_name
                temp_final_result_str << ","
            }
            @classes.delete_if {|find_result| temp_final_result_str.include?(find_result.fr_name) }
            puts "\033[32m查找结束，共同无用文件#{@classes.size}个,如下：\033[0m"
            Spreadsheet.client_encoding = 'utf-8'
            book = Spreadsheet::Workbook.new
            sheet1 = book.create_worksheet
            sheet1.row(0)[0] = "序号"
            sheet1.row(0)[1] = "文件名"
            sheet1.row(0)[2] = "文件路径"
            total_size = 0
            @classes.each_with_index{|r_item,f_index| 
                # if !r_item.fr_name.include?("+")
                    total_size = total_size + File.size(r_item.fr_path)
                # end
                puts r_item.fr_name
                sheet1.row(f_index+1)[0] = f_index + 1
                sheet1.row(f_index+1)[1] = r_item.fr_name
                sheet1.row(f_index+1)[2] = r_item.fr_path
                sheet1.row(f_index+1).height = 20
            }
            sheet1.column(0).width = 4
            sheet1.column(1).width = 45
            sheet1.column(2).width = 100
            book.write "#{@search_path}/search_unuseclass_result.xls"
            puts "\033[32m文件已经保存到#{@search_path}/search_unuseclass_result.xls,无用文件#{@classes.size}个,预计可减少内存占用#{handleSize(total_size)}\033[0m"
        end
        # 大小格式化
        def handleSize(size)
            if size > 1024 * 1024
               return format("%.2f",(size.to_f/(1024*1024))) + "MB"
            elsif size > 1024
               return format("%.2f",(size.to_f/1024)) + "KB"
            else
               return size.to_s + "B"
            end
         end
        # 不包含后缀的路径
        def get_no_ext_path(item)
            return  File.dirname(item) + "/" + File.basename(item,".*")
        end
        # 不需要查找的类
        def get_not_contain_file_ext
            nc_ext = [".jpg",".png",".md",".xls",".xcworkspace",".DS_Store",""]
            return nc_ext
        end
        # 对外暴露
        def self.search_unuse_class(args)
            folder_path = args[0]
            if folder_path.nil?
                puts "\033[31m传入的参数不能为空\033[0m"
                return
            end
            if !File::directory?(folder_path)
                puts "\033[31m参数不是文件夹\033[0m"
                return
            end
            class_finder = ClassFinder.new(folder_path)
            class_finder.search
        end
    end

# ------------------------查找结果类------------------------

    class FindResult
        attr_accessor :fr_name, :fr_path
        def initialize(temp_name,temp_path)
            @fr_name = temp_name
            @fr_path = temp_path
        end
    end
end