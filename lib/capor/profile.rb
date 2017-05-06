#!/usr/bin/env ruby

require 'commander/import'
require 'zip'
require 'zip/filesystem'
require 'plist'
require 'terminal-table'

program :name, 'capor'
program :version, '0.0.1'
program :description, 'Get ipa info'
program :help, 'Author', 'gumpwang  <gumpwang2016@gmail.com>'


command :profile do |c|
  c.syntax = 'capor profile [options]'
  c.summary = 'this is summary add by summary'
  c.description = 'this is the description add by wanggang'
  # password
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'

  c.option '--prefix STRING', String, 'Adds a prefix to bar'
  c.option '--suffix STRING', String, 'Adds a suffix to bar'
  # choice = choose("Favorite language?", :ruby, :perl, :js)

  c.action do |args, options|
    # Do something or c.when_called Nopo::Commands::Info
    # say 'foo'
    # say args.to_s
    # say options.to_s
    # options.default :prefix => '(', :suffix => ')'

    # @file = args.pop
    determine_file! unless @file = args.pop
    say_error "Missing or unspecified .ipa file" and abort unless @file and ::File.exist?(@file)

    # say @file

    puts "----> #{File.basename(@file, File.extname(@file))}.app"

    # find .app entry
    Zip::File.open(@file) do |zipfile|
      puts zipfile
      app_entry = zipfile.find_entry("Payload/#{File.basename(@file, File.extname(@file))}.app")
      provisioning_profile_entry = zipfile.find_entry("#{app_entry.name}embedded.mobileprovision") if app_entry

      if (!provisioning_profile_entry)
        zipfile.dir.entries("Payload").each do |dir_entry|
          if dir_entry =~ /.app$/
            say "Using .app: #{dir_entry}"
            app_entry = zipfile.find_entry("Payload/#{dir_entry}")
            provisioning_profile_entry = zipfile.find_entry("#{app_entry.name}embedded.mobileprovision") if app_entry
            puts "zipname is : #{app_entry}"
            puts "provisioning_profile_entry is : #{provisioning_profile_entry}"
            break
          end
        end
      end
      say_error "Embedded mobile provisioning file not found in #{@file}" and abort unless provisioning_profile_entry


      # puts "===> #{Dir.mktmpdir}"
      tempdir = ::File.new(Dir.mktmpdir)

      puts tempdir.path

      begin
        puts "zipfile is : #{zipfile}"
        zipfile.each do |zip_entry|
          temp_entry_path = ::File.join(tempdir.path, zip_entry.name)
          FileUtils.mkdir_p(::File.dirname(temp_entry_path))
          zipfile.extract(zip_entry, temp_entry_path) unless ::File.exist?(temp_entry_path)
        end

        temp_provisioning_profile = ::File.new(::File.join(tempdir.path, provisioning_profile_entry.name))
        puts "temp_provisioning_profile is : #{temp_provisioning_profile}"
        temp_app_directory = ::File.new(::File.join(tempdir.path, app_entry.name))
        puts "temp_app_directory is : #{temp_app_directory.path}"

        plist = Plist::parse_xml(`security cms -D -i "#{temp_provisioning_profile.path}"`)
        # puts "---> plist is : #{plist}"

        codesign = `codesign -dv "#{temp_app_directory.path}" 2>&1`
        puts "---->>>>> codesign is : #{codesign}"
        codesigned = /Signed Time/ === codesign
        puts "====>>>>> codegigned is : #{codesigned}"

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

          t << ["Codesigned", codesigned.to_s.capitalize]
        end

        puts table
      end


    end


    # say "#{options.prefix}bar#{options.suffix}"
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

