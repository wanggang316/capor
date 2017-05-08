#!/usr/bin/env ruby

module Capor
  mudule FileManager
    def determine_file!

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


    end
  end

end
