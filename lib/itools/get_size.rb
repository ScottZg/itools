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
            sum = 0
            file_count = 0
            Find.find(folder) do |filename|
                if File.file?(filename)
                    sum = sum + File.size(filename)
                    file_count = file_count + 1
                    # puts "#{File.basename(filename)}的大小为：#{get_show_size(File.size(filename))}"
                end
            end
            puts "\033[32m文件夹中共#{file_count}个文件，共占用内存大小为：#{get_show_size(sum)}.\033[0m"
            # puts `du -b #{folder} | awk '{print $1}'`.to_i 
        end
        # get_show_size 
        def get_show_size(size)
            if size > @pro * @pro
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