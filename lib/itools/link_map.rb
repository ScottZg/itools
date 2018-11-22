require 'fileutils'
require 'pathname'

module Itools
        # ---------------------------------ObjectFile class---------------------------------
    class ObjectFile
        attr_accessor :serial_number, :file_path, :file_name
        def initialize()
            @serial_number = []
        end

    end
    # ---------------------------------Sections class---------------------------------
    class Sections
        attr_accessor :address, :size, :segment, :section

    end
    # ---------------------------------Symbols class---------------------------------
    class Symbols
        attr_accessor :s_address, :s_size, :s_file_serial_number, :s_name
        def initialize
            @s_file_serial_number = -1   #防止为0
        end
    end

    # ---------------------------------DSSymbols class---------------------------------
    class DSSymbols
        attr_accessor :size, :file, :name
    end

    # ---------------------------------LinkMap class---------------------------------
    class LinkMap
        # 包含的属性
        attr_accessor :l_name, :l_path, :l_arch, :l_obj_files, :l_sections, :l_symbols, :l_dead_stripped_symbols, :l_sym_map
        # 初始化方法
        def initialize(fName)
            @l_name = fName
            @l_obj_files = []
            @l_symbols = []
            @l_sections = []
            @l_dead_stripped_symbols = []
        end
    #    得到path
        def get_path(str)
            splitparam = str.split(" ")
            @l_path = splitparam.last
        end
    # 处理object文件
        def handle_ojbect_files(str)
            tempSplit = str.split("]")    
            if tempSplit.size > 1
                obj_file = ObjectFile.new
                obj_file.serial_number = tempSplit[0].delete("[").strip.to_i   #设置serial_number
                obj_file.file_path = tempSplit[1].strip
                obj_file.file_name = tempSplit[1].split("/").last.chomp
                l_obj_files << obj_file
            end
        end
    # 处理sections
        def handle_sections(str)
            sectionSplit = str.split(" ")
            if sectionSplit.size == 4
                section = Sections.new
                section.address = sectionSplit[0]
                section.size = sectionSplit[1]
                section.segment = sectionSplit[2]
                section.section = sectionSplit[3]
                l_sections << section
            end
        end
        # get arch
        def get_arch(str)
            splitparam = str.split(" ")
            @l_arch = splitparam.last
        end
    # 处理Symbols
        def handle_symbols(str)
            # 字符编码产生的异常处理
            begin
                symbolsSplit = str.split("\t")
            rescue => exception
                return
            end
            if symbolsSplit.size > 2
                symbol = Symbols.new
                symbol.s_address = symbolsSplit[0]
                symbol.s_size = symbolsSplit[1]
                # 获取编号和名字
                serial_name_str = symbolsSplit[2]
                file_and_name_split = serial_name_str.split("]")
                if file_and_name_split.size > 1
                    symbol.s_file_serial_number = file_and_name_split[0].delete("[").strip.to_i  #设置文件编号
                    symbol.s_name = file_and_name_split[1]
                end
                
                l_symbols << symbol
            else
            end
        end
        # 处理symbols的数组,把symbols转换成hashmap
        def handle_l_sym_map
            @l_sym_map = @l_symbols.group_by(&:s_file_serial_number)
            if @l_sym_map.include?(-1)
                puts "移除无用元素"
                @l_sym_map.delete(-1)
            end
        end
        # 处理link map file
        def handle_map
            handle_method_name = ""
            File.read(@l_name).each_line do |line|
                if line[0] == "#"
                    if line.include?("Path:")
                    handle_method_name =  "get_path"
                    puts "处理path..."
                    elsif line.include?("Arch:")
                        handle_method_name = "get_arch"
                        puts "处理Arch..."
                    elsif line.include?("Object files")
                        handle_method_name = "handle_ojbect_files"
                        puts "处理Object files..."
                    elsif line.include?("Sections")
                        handle_method_name = "handle_sections"
                        puts "处理Sections..."
                    elsif line.include?("Symbols:")   #symbols:和Dead Stripped Symbols处理一样    
                        puts "处理#{line.delete('#').strip}..."
                        handle_method_name = "handle_symbols"
                    end
                end
                self.send(handle_method_name, line)
            
            end
        end
        def self.parser(path_para)           
            start_time = Time.now.to_i    #程序开始执行时间（以毫秒为单位）
            # 获取link map file's name
            link_map_file_name = path_para
            puts "获取的文件路径为：#{link_map_file_name}"
            if link_map_file_name.nil?
                puts "请按照如下命令执行该脚本："
                puts "\033[31mruby linkMapParse.rb **.txt \033[0m"
                puts "**指代Link Map File的名字，例如LinkMapApp-LinkMap-normal-x86_64.txt"
                exit
            end
            if File.exist?(link_map_file_name)
                puts "\033[32m获取LinkMap文件: #{link_map_file_name}成功，开始分析数据...\033[0m"    
            else
                puts "\033[31m#{link_map_file_name}文件不存在，请重新输入文件 \033[0m"
                exit
            end

            link_map = LinkMap.new(link_map_file_name)
            link_map.handle_map #处理文件为对象，然后继续后续操作
            link_map.handle_l_sym_map  #处理symbols为hashmap
            sizeResultArr = []

            link_map.l_obj_files.each do |obj|
                temp_file_name = obj.file_name.split("(")[0]
                
                last_file = sizeResultArr.last
                
                if last_file && temp_file_name.eql?(last_file.file_name) 
                    last_file.file_serial_numers << obj.serial_number
                else
                    sz_obj = SizeResult.new
                    sz_obj.file_name = temp_file_name
                    sz_obj.file_serial_numers << obj.serial_number
                    sizeResultArr << sz_obj
                end
            end
            data_analyze_time = Time.now.to_i
            puts "\033[32m数据分析完成，耗时#{data_analyze_time - start_time}秒。开始计算结果\033[0m"    

            # 计算赋值size,此处耗时较长
            total_size = 0
            sizeResultArr.each do |obj|
                # 处理方法2
                obj.file_serial_numers.each do |s_number|
                    begin
                        link_map.l_sym_map[s_number].each do |symb|
                            obj.size = obj.size + symb.s_size.hex
                            total_size = total_size +symb.s_size.hex  #统计总大小
                        end
                    rescue => exception     
                    end
                end
                # 处理方法1 太过耗时
                # link_map.l_symbols.each do |symb|
                #     if obj.file_serial_numers.include?(symb.s_file_serial_number)
                #         obj.size = obj.size + symb.s_size.hex
                #     end
                # end
                # puts "正在计算#{obj.file_name}的大小..."
            end
            data_handle_time = Time.now.to_i  #处理数据时间
            puts "\033[32m数据处理完成，耗时#{data_handle_time - data_analyze_time}秒。开始对结果进行大小排序（从大到小）...\033[0m"    
            # 按照从大到小排序
            sizeResultArr.sort_by!{|obj|[-obj.size]}
            sort_handle_time = Time.now.to_i  #排序耗时
            puts "\033[32m数据排序完成，耗时#{sort_handle_time - data_handle_time}秒。开始输出结果：\033[0m"    
            puts "\033[32m--------------------------------\033[0m"  

            # 判断文件是否存在
            save_file_path = SizeResult.getSaveFileName
            if File.exist?(save_file_path)
                File.delete(save_file_path)
            end

            # 创建要保存数据的文件
            save_file = File.new(save_file_path,"w+")
            # 打印结果  
            sizeResultArr.each do |obj|
                puts "#{obj.file_name}          " + SizeResult.handleSize(obj.size)
                save_file.puts("#{obj.file_name}          #{SizeResult.handleSize(obj.size)}")
            end
            save_file.puts("总大小为：#{SizeResult.handleSize(total_size)}")
            save_file.close
            puts "总大小为(仅供参考)：#{SizeResult.handleSize(total_size)}"
            puts "\033[32m--------------------------------\033[0m"
            end_time = Time.now.to_i   #程序执行结束时间
            puts "分析结果已经保存为文件，位置为：\n\033[32m#{save_file_path}\033[0m"
            puts " "
            puts "\033[32m整个程序执行时间为：#{end_time - start_time}秒\033[0m"
        end
        
    end
    # --------------------------------- Size utils class ---------------------------------
    class SizeResult
        attr_accessor :file_name, :file_serial_numers, :size
        def initialize
            @file_serial_numers = []
            @size = 0
        end
        # size字符化
        def self.handleSize(size)
        if size > 1024 * 1024
                return format("%.2f",(size.to_f/(1024*1024))) + "MB"
            elsif size > 1024
                return format("%.2f",(size.to_f/1024)) + "KB"
            else
                return size.to_s + "B"
            end
        end
        # 获取结果文件保存到目录
        def self.getSaveFileName(path_para)
            path = Pathname.new(path_para)
            # 要保存的地址
            save_file_path = path.dirname.to_s + "/" + "parse_" + path.basename.to_s + "_result.txt"
            return save_file_path
        end
    end
end