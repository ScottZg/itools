require 'find'
module Itools
    class CodeCouner
        attr_accessor :file_path, :line_number
        def initialize(path)
            @file_path = path
            @line_number = 0
        end
        # 统计行数
        def calculate_line_number    
            puts "\033[32m正在统计，请稍后...\033[0m"
            if File.file?(@file_path)
                File.read(@file_path).each_line do |line|
                    if line.match(/^\/\/|^$/) == nil   #去掉单行注释和空行
                        @line_number = @line_number + 1  
                    end
                end
                puts "\033[32m统计#{counter.file_path}结束，共#{counter.line_number}行\033[0m"
                return
            end
            if File::directory?(@file_path)
                Find.find(@file_path) do |file|
                    if File.file?(file) #判断是否是文件
                        if File.extname(file).match(/^.[hm]m?$|.cpp/)  #只统计.h/.m/.mm/.cpp几个文件
                            File.read(file).each_line do |line|
                                if line.match(/^\/\/|^$/) == nil   #去掉单行注释和空行 
                                    @line_number = @line_number + 1  
                                end
                            end
                        end
                    end
                end
                puts "\033[32m统计#{counter.file_path}结束，共#{counter.line_number}行\033[0m"
                return
            end
            puts "\033[31m找不到指定路径的文件或者文件夹，请重新输入路径\033[0m"
        end

        def self.counter(args)
            file = args[0]
            if file.nil?
                puts "\033[31m参数异常，请传入一个参数(项目目录/要统计的文件目录/要统计的文件)\033[0m"
                return
            end
            counter = CodeCouner.new(file)
            counter.calculate_line_number
        end
    end
end