require 'find'
require 'spreadsheet'
module Itools
   class FindResult
      attr_accessor :name , :path
      def initialize(name,path)
         @name = name
         @path = path
      end

   end
   # --------------------------------------------
   class ImgFinder
      # 
      attr_accessor :image_count, :images, :unuse_images,:find_path
      attr_accessor :search_files
      def initialize
         @image_count = 0
         @images = []
         @search_files = []
      end
      # 得到所有图片名称字符
      def get_img_name_strs
         result_arr = []
         @images.each {|item|
            item_name = Image.get_image_name(File.basename(item.name, ".*"))
            result_arr << item_name
         }
         return result_arr
      end
      def get_image_path(image)
         @images.each {|item|
            if item.name.eql?(image)
               return item.path
            end
         }
      end
      # 查找
      def self.find(temp_find_dir)
         imgFinder = ImgFinder.new
         imgFinder.find_path = temp_find_dir
         # 第一步：找到该文件夹下所有的图片文件
         Find.find(temp_find_dir) do |filename|
            if File.file?(filename)   #如果是文件，则从文件中查找，忽略文件夹
               if Image.is_image_format(File.extname(filename))
                  # p File.basename(filename)
                  # exit
                  imgFinder.image_count = imgFinder.image_count + 1
                  imageResult = FindResult.new(Image.get_image_name(File.basename(filename,".*")),filename)
                  imgFinder.images << imageResult
               elsif File.extname(filename).eql?(".m") || File.extname(filename).eql?(".swift")
                  imgFinder.search_files << filename
               end
            end
         end
         if imgFinder.images.size == 0
            puts "\033[32m查找成功,未发现图片\033[0m"
            return
         else
            puts "\033[32m查找成功,共发现图片#{imgFinder.images.size}张\033[0m"
         end
         # 第二步：找到图片是否使用
         imags = imgFinder.get_img_name_strs.uniq   #要查找的图片名称数组

        puts "\033[32m需要查找的图片有#{imags.size}张\033[0m"
        #  imgFinder.search_files   #要查找的文件
         imgFinder.search_files.each {|file|
            File.read(file).each_line do |line|
                haveStr = StringHandle.containsStr(line,imags)
                if haveStr != -1
                    puts "#{imags[haveStr]}在使用...,剩余查找项#{imags.size-1}个"           
                    imags.delete_at(haveStr)
               end
            end
         }
         puts "\033[32m无用图片#{imags.size}张,图片名称如下:\033[0m"
         unuse_total_size = 0
       
         Spreadsheet.client_encoding = 'utf-8'
         book = Spreadsheet::Workbook.new
         sheet1 = book.create_worksheet
         sheet1.row(0)[0] = "文件名"
         sheet1.row(0)[1] = "文件路径"
         sheet1.row(0)[2] = "文件大小(B)"
         imags.each_with_index {|item,idx|
            sheet1.row(idx+1)[0] = item
            path = imgFinder.get_image_path(item)
            sheet1.row(idx+1)[1] = path
            unuse_total_size = unuse_total_size + File.size(path)
            sheet1.row(idx+1)[2] = File.size(path)
            puts item
        }
         book.write "#{imgFinder.find_path}/search_result.xls"
         puts "\033[32m文件已经保存到#{imgFinder.find_path}/search_result.xls,无用图片大小：#{unuse_total_size}B\033[0m"
         puts "\033[32m内容仅供参考，具体还要自己通过结果查看一下\033[0m"
      end
   end
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
   # ----------------------------
   class Image

      # 是否是图片格式,这里只判断了jpg、png和gif
      def self.is_image_format(temp_ext_name)
         if ['.jpg','.png','.gif'].include?(temp_ext_name)
            return true
         else
            return false
         end
      end
      def self.get_image_name(file)
         return file.gsub(/@2x|@3x/,"")
      end
   end
   # class ObjectiveC
   #     def self.is_h_file(temp_ext_name)
   #         if ['.h']

   #         end
   #     end
   # end
end
