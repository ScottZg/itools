require 'find'
module Itools
    class Memory
        attr_accessor :pro
        # 分发吹
        def hand_cal_size(file,prop)
            if prop.nil?
                @pro = 1024
            elsif prop == 0
                @pro = 1024
            else
                @pro = prop
            end
            handle_method = ''
            if File.file?(file)
                puts "\033[32m开始计算文件的大小...\033[0m"
                handle_method = 'cal_file'
            elsif File::directory?(file)
                handle_method = 'cal_folder'
                puts "\033[32m开始计算文件夹的大小...\033[0m"    
            else
                puts "\033[31m参数异常，请确保传入的第一个参数是文件路径或者文件夹路径\033[0m"
                return
            end
            self.send(handle_method,file)
        end
        # 计算单个文件
        def cal_file(file)
            puts "\033[32m文件的大小为：#{get_show_size(File.size(file))}.\033[0m"
        end
        # 计算整个文件夹
        def cal_folder(folder)
            print "\033[32m请输入要查找文件后缀\033[0m（例如想文件夹中图片大小则输入：{png,jpg,gif},不输入则默认计算文件夹下所有文件大小之和）:"
            file_exts_string = STDIN.gets
            file_exts_string.chomp!   #过滤换行符
            if file_exts_string.size == 0
                file_exts = []
            else
                file_exts = file_exts_string.split(",")
            end
            sum = 0
            file_count = 0
            total_count = 0
            total_size = 0
            file_size = 0
            Find.find(folder) do |filename|
                if File.file?(filename)
                    total_count = total_count + 1
                    total_size = total_size + File.size(filename)
                    if file_exts.size == 0  #说明计算所有文件
                        sum = sum + File.size(filename)
                        file_count = file_count + 1
                    elsif file_exts.include?(File.extname(filename).delete("."))   #查找指定后缀的文件
                        sum = sum + File.size(filename)
                        file_count = file_count + 1
                        file_size = file_size + File.size(filename)
                    else
                        #不做任何处理
                    end
                end
            end
            if file_exts.size == 0
                puts "\033[32m文件夹中共#{total_count}个文件，共#{get_show_size(total_size)}(#{total_size})\033[0m"
            else
                puts "\033[32m文件夹中共#{total_count}个文件，共#{get_show_size(total_size)}(#{total_size})；找到后缀为(#{file_exts_string})的文件#{file_count}个，共#{get_show_size(file_size)}(#{file_size}).\033[0m"
            end
            
            # puts `du -b #{folder} | awk '{print $1}'`.to_i 
        end
        # get_show_size 
        def get_show_size(size)
            if size > @pro * @pro * @pro
                return format("%.2f",(size.to_f/(@pro*@pro*@pro))) + "GB"
             elsif size > @pro * @pro
                return format("%.2f",(size.to_f/(@pro*@pro))) + "MB"
             elsif size > @pro
                return format("%.2f",(size.to_f/@pro)) + "KB"
            else
                return size.to_s + "B"
             end
        end
         # 对外暴露方法
         def self.sizeFor(proport)
            file = proport[0]
            pro = proport[1].to_i
            if file.nil?
                puts "\033[31m参数异常，请传入一个参数\033[0m"
                return
            end
            memory = Memory.new
            memory.hand_cal_size(file,pro)
        end
    end
end