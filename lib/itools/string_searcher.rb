require 'find'
require 'spreadsheet'
module Itools
   # 字符串操作类
   class StringHandle
      # originStr中是否包含targetStrs中的内容
      def self.containsStr(originStr,targetStrs)
         targetStrs.each_with_index {|item,idx|
            if originStr.include?(item)
               return idx
            end
         }
         return -1
      end
   end
   # 搜索结果类
   class SearchResult
      attr_accessor :file_name, :in_line, :result_str, :key_str

      def initialize(tempName,tempInLine,tempResultStr,tempKeyStr)
         @file_name = tempName
         @in_line = tempInLine
         @result_str = tempResultStr
         @key_str = tempKeyStr
      end
   end

   # Main class
   class StringSearcher
      attr_accessor :search_strs, :search_in, :result
      def initialize(temp_SearchStrs,temp_SearchIn)
         @search_strs = temp_SearchStrs
         @search_in = temp_SearchIn
         @result = []
      end
      #  第二步开始搜索
      def search
         if check_exist
            handle_method = ''
            if File.file?(@search_in)   #如果是文件
               handle_method = "search_in_file"
            else
               handle_method = "search_in_folder"
            end
            self.send(handle_method,@search_in)
         else
            puts "\033[31m文件不存在，请检查输入是否正确\033[0m"
            exit
         end
      end
      # 从文件查找
      def search_in_file(temp_file)
         line_index = 1
         File.read(temp_file).each_line do |line|
            haveIndex = StringHandle.containsStr(line,@search_strs)
            if haveIndex != -1
               search_result = SearchResult.new(temp_file,line_index,line,@search_strs[haveIndex])
               @result << search_result
            end
            line_index = line_index + 1
         end
      end

      # 从文件夹查找
      def search_in_folder(unuse)
         puts @search_in_folder
         Find.find(@search_in) do |filename|
            if File.file?(filename)   #如果是文件，则从文件中查找，忽略文件夹
               search_in_file(filename)
            end
         end
      end
      # 第一步：检查是否存在
      def check_exist
         if File.file?(@search_in)
            puts "\033[32m从文件中查找\033[0m"
            return true
         elsif File::directory?(@search_in)
            puts "\033[32m从文件夹中查找\033[0m"
            return true
         else
            return false
         end
      end
      # 第一个参数为要搜索的文件或者文件夹名称
      # 第二个参数为要搜索的字符串
      def self.search_result(temp_search_in,temp_search_strs)
         if temp_search_in.nil? 
            puts "\033[31m传入的参数有误，第一个参数为要搜索的文件或者文件夹名称，第二个参数为要搜索的字符串(如要查找多个str使用英文,分割),两个参数中间用空格区分\033[0m"
            exit
         end
         if temp_search_strs.nil?
            puts "\033[31m传入的参数有误，第一个参数为要搜索的文件或者文件夹名称，第二个参数为要搜索的字符串(如要查找多个str使用英文,分割),两个参数中间用空格区分\033[0m"
            exit
         end
         # 传入的可能是字符串数组
         searcher = StringSearcher.new(temp_search_strs.split(","),temp_search_in)
         searcher.search
         if searcher.result.size == 0
            puts "\033[32m没有找到相关字段\033[0m"
            exit
         end
         # 输出搜索的内容
         Spreadsheet.client_encoding = 'utf-8'
         book = Spreadsheet::Workbook.new
         sheet1 = book.create_worksheet
         sheet1.row(0)[0] = "文件名"
         sheet1.row(0)[1] = "包含字符串"
         sheet1.row(0)[2] = "文件所在目录"
         sheet1.row(0)[3] = "查找内容所在行"
         sheet1.row(0)[4] = "查找结果Str"

         searcher.result.each_with_index do |item,i|
            sheet1.row(i+1)[0] = File.basename(item.file_name)
            sheet1.row(i+1)[1] = item.key_str
            sheet1.row(i+1)[2] = File.dirname(item.file_name)
            sheet1.row(i+1)[3] = item.in_line
            sheet1.row(i+1)[4] = item.result_str
         end

         puts "\033[32m查找成功,内容已经保存到#{File.dirname(searcher.search_in)}，请点击查看\033[0m"
         book.write "#{File.dirname(searcher.search_in)}/find_result.xls"
      end
   end
end
