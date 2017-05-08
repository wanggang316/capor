#!/usr/bin/env ruby

require 'commander/import'
require 'zip'
require 'zip/filesystem'
require 'terminal-table'
require 'cfpropertylist'

program :name, 'capor'
program :version, '0.0.1'
program :description, 'Get ipa info'
program :help, 'Author', 'gumpwang  <gumpwang2016@gmail.com>'


command :info do |c|
  c.syntax = 'capor info [options]'
  c.summary = 'this is summary add by summary'
  c.description = 'this is the description add by wanggang'
  c.example 'description', 'command example'

  c.action do |args, options|
    determine_file! unless @file = args.pop
    say_error "Missing or unspecified .ipa file" and abort unless @file and ::File.exist?(@file)

    # say @file

    puts "----> #{File.basename(@file, File.extname(@file))}.app"


  end



  # read
  def readFile(file)
    # find .app entry
    Zip::File.open(file) do |zipfile|
      puts zipfile
      app_entry = zipfile.find_entry("Payload/#{File.basename(@file, File.extname(@file))}.app")
      info_entry = zipfile.find_entry("#{app_entry.name}embedded.mobileprovision") if app_entry

      if (!info_entry)
        zipfile.dir.entries("Payload").each do |dir_entry|
          if dir_entry =~ /.app$/
            say "Using .app: #{dir_entry}"
            app_entry = zipfile.find_entry("Payload/#{dir_entry}")
            info_entry = zipfile.find_entry("#{app_entry.name}Info.plist") if app_entry
            puts "zipname is : #{app_entry}"
            puts "Info.plist is : #{info_entry}"
            break
          end
        end
      end
      say_error "Embedded mobile provisioning file not found in #{@file}" and abort unless info_entry


      tempdir = ::File.new(Dir.mktmpdir)

      puts tempdir.path

      begin
        puts "zipfile is : #{zipfile}"
        zipfile.each do |zip_entry|
          temp_entry_path = ::File.join(tempdir.path, zip_entry.name)
          FileUtils.mkdir_p(::File.dirname(temp_entry_path))
          zipfile.extract(zip_entry, temp_entry_path) unless ::File.exist?(temp_entry_path)
        end

        temp_info_plist = ::File.new(::File.join(tempdir.path, info_entry.name))
        puts "temp_info_plist is : #{temp_info_plist.path}"
        temp_app_directory = ::File.new(::File.join(tempdir.path, app_entry.name))
        puts "temp_app_directory is : #{temp_app_directory.path}"

        plist ||= CFPropertyList.native_types(
            CFPropertyList::List.new(file: temp_info_plist).value)

        # print
        printPlist(plist)
      end
    end

  end


  # print
  def printPlist(plist)
      table = Terminal::Table.new do |t|
        plist.each do |key, value|
          next if key == "DeveloperCertificates"

          columns = []
          columns << key
          columns << case value
                     when Hash
                       value.collect{|k, v| "#{k}: #{v}"}.join("\n")
                     when Array
                       value.join("\n")
                     else
                       value.to_s
                     end

          t << columns
          t << :separator

        end
      end
      puts table
  end




  def determine_file!
    files = Dir['*.ipa']
    @file ||= case files.length
              when 0 then nil
              when 1 then files.first
              else
                @file = choose "Select an .ipa File:", *files
              end
  end
end

