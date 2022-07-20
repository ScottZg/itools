require 'fileutils'
require 'pathname'
require 'find'
require 'spreadsheet'
module Itools
   # ---------------------------------ObjectFile class---------------------------------
   class ObjectFile
      # file_size:单个文件的大小
      # o_name：某个文件的名字
      # o_size: 某个o文件的大小
      attr_accessor :serial_number, :file_path, :file_name, :file_size, :o_name, :o_size
      def initialize()
         @serial_number = []
         @file_size = 0
         @o_size = 0
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
            obj_file.o_name = get_o_name(tempSplit[1].split("/").last.chomp)
            l_obj_files << obj_file
         end
      end
      # 得到o_ame  有待优化，可以使用正则表达式处理TODO
      def get_o_name(str)
         temp_arr = str.split("(")
         if temp_arr.size > 1
            temp_arr[1].split(".o)")[0]
         else
            return temp_arr[0].split(".o")[0]
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
               #   这里不处理Dead Stripped Symbols
                  if line.delete('#').strip.include?("Dead Stripped Symbols")
                     puts "不处理处理#{line.delete('#').strip}..."
                     break
                  end
                  puts "处理#{line.delete('#').strip}..."
                  handle_method_name = "handle_symbols"
               end
            end
            self.send(handle_method_name, line)

         end
      end
      # 对linkmap进行解析，然后输出结果
      def self.parser(path_para)
         start_time = Time.now.to_i    #程序开始执行时间（以毫秒为单位）
         # 获取link map file's name
         link_map_file_name = path_para
         puts "获取的文件路径为：#{link_map_file_name}"
         if link_map_file_name.nil?
            puts "请按照如下命令执行该脚本："
            puts "\033[31mitools parse  **.txt \033[0m"
            puts "**指代Link Map File的名字，例如LinkMapApp-LinkMap-normal-x86_64.txt,parse后面为绝对路径"
            return
         end
         if File.exist?(link_map_file_name)
            puts "\033[32m获取LinkMap文件: #{link_map_file_name}成功，开始分析数据...\033[0m"
         else
            puts "\033[31m#{link_map_file_name}文件不存在，请重新输入文件 \033[0m"
            return
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
         save_file_path = SizeResult.getSaveFileName(path_para)
         if File.exist?(save_file_path)
            File.delete(save_file_path)
         end

         # 创建要保存数据的文件
         Spreadsheet.client_encoding = 'utf-8'
         book = Spreadsheet::Workbook.new
         sheet1 = book.create_worksheet
         sheet1.row(0)[0] = "文件名"
         sheet1.row(0)[1] = "文件大小(B)"
         sheet1.row(0)[2] = "文件大小"
         sizeResultArr.each_with_index{|item, idx|
         sheet1.row(idx+1)[0] = item.file_name
         sheet1.row(idx+1)[1] = item.size
         sheet1.row(idx+1)[2] = SizeResult.handleSize(item.size)
      }
      book.write "#{save_file_path}"
         # save_file = File.new(save_file_path,"w+")
         # # 打印结果
         # sizeResultArr.each do |obj|
         #    puts "#{obj.file_name}          " + SizeResult.handleSize(obj.size)
         #    save_file.puts("#{obj.file_name}          #{SizeResult.handleSize(obj.size)}(#{obj.size})")
         # end
         # save_file.puts("总大小为：#{SizeResult.handleSize(total_size)}")
         # save_file.close
         puts "总大小为(仅供参考)：#{SizeResult.handleSize(total_size)}"
         puts "\033[32m--------------------------------\033[0m"
         end_time = Time.now.to_i   #程序执行结束时间
         puts "分析结果已经保存为文件，位置为：\n\033[32m#{save_file_path}\033[0m"
         puts " "
         puts "\033[32m整个程序执行时间为：#{end_time - start_time}秒\033[0m"
      end

      # 根据linkmap && folder计算占用
      # 第一个参数为linkmap路径，第二个参数为要分析的项目文件夹
      def self.parser_by_folder(args)
         link_map_file_name = args[0]    #linkmap文件路径
         project_folder = args[1] #项目文件夹
         # 对参数进行校验
         if File::directory?(project_folder)
            puts "获取的项目目录路径为：#{project_folder}"
         else
            puts "\033[31m#{project_folder}文件夹不存在，请重新输入 \033[0m"
            return
         end
         if File.exist?(link_map_file_name)
            puts "获取的linkmap文件路径为：#{link_map_file_name}"
            puts "\033[32m获取LinkMap文件: #{link_map_file_name}成功，开始分析数据...\033[0m"
         else
            puts "\033[31m#{link_map_file_name}文件不存在，请重新输入 \033[0m"
            return
         end
         # 开始处理数据
         link_map = LinkMap.new(link_map_file_name)
         link_map.handle_map #处理文件为对象，然后继续后续操作
         link_map.handle_l_sym_map  #处理symbols为hashmap

         # 所有的文件
         link_map.l_obj_files
         # 所有的symbols
         link_map.l_symbols

         # 处理得到每个obj_file的大小
         link_map.l_obj_files.each do |obj|
            if link_map.l_sym_map[obj.serial_number]
               link_map.l_sym_map[obj.serial_number].each do |symb|
                  obj.o_size = obj.o_size + symb.s_size.hex
               end
            end
         end
         # key为文件名，value为ojbect
         sort_by_obj_files_map = link_map.l_obj_files.group_by(&:o_name)
         # save_file_path = SizeResult.getSaveFileName(project_folder)
         # save_file = File.new(save_file_path,"w+")
         # sort_by_obj_files_map.keys.each do |sss|

         #    save_file.puts("#{sort_by_obj_files_map[sss][0].o_name}   #{sort_by_obj_files_map[sss][0].o_size}")
         # end
         # save_file.close
         # exit



         size_results = [] #盛放计算结果
         size_files = []
         space_index = 0
         puts "计算开始"
         traverse_dir(sort_by_obj_files_map,project_folder,size_results,size_files,space_index)
         size_results.reverse!
         # 存储为文件
         save_file_path = SizeResult.getSaveFileName(project_folder)
         if File.exist?(save_file_path)
            File.delete(save_file_path)
         end
         save_file = File.new(save_file_path,"w+")
         o_index = 2
         size_results.each do |o|
            result_str = "#{' ' * o.space_count}├── #{o.folder_name.split('/').last}    #{SizeResult.handleSize(o.size)}(#{o.size})"
            save_file.puts(result_str)
         end
         save_file.close
         puts "分析结果已经保存为文件，位置为：\n\033[32m#{save_file_path}\033[0m"
      end
      def self.traverse_dir(sort_by_obj_files_map,file_path,results,size_files,space_index)
         s_result = SizeResult.new
         s_result.folder_name = file_path  
         space_index = space_index + 2 
         file_name_arr = [] #盛放计算过的类
         Find.find(file_path) do |file|
            # 不包含图片
            if File.file?(file) && !(File.extname(file) =~ /(png|gif|jpg|bmp|jpeg)/)
               file_name = File.basename(file,".*")
               if !file_name_arr.include?(file_name) && sort_by_obj_files_map[file_name] #没有已经计算过
                  s_result.size = s_result.size + sort_by_obj_files_map[file_name][0].o_size
                  file_name_arr << file_name
               end
            elsif File::directory?(file) && file != file_path
               traverse_dir(sort_by_obj_files_map,file,results,size_files,space_index)
            end
         end
         if s_result.size > 0 && !size_files.include?(s_result.folder_name)
            s_result.space_count = space_index
            results << s_result
            size_files << s_result.folder_name
         end
      end
   end
   class SizeResult
      attr_accessor :file_name, :file_serial_numers, :size,:folder_name, :space_count
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
         save_file_path = path.dirname.to_s + "/" + "parse_" + path.basename.to_s + "_result(#{Time.new.strftime("%Y%m%d%H%M%S")}).xls"
         return save_file_path
      end
   end   
end

# --------------------------------- Size utils class ---------------------------------
