#!/usr/bin/env ruby

# ipa package class
class Package

  def initialize(path)
    @path = path
  end


  ############### Info.plist ##################

  def info
    @info ||= CFPropertyList.native_types(
      CFPropertyList::List.new(file: File.join(@path, 'Info.plist')).value)
  end

  # app name
  def name
    @info['CFBundleName']
  end

  # 住百家
  def display_name
    info['CFBundleDisplayName']
  end

  # bundle identifier, eg. com.zhubaijia.xxx
  def bundle_identifier
    @info['CFBundleIdentifier']
  end

  # build is the bundle version, eg. 1234
  def build
    @info['CFBundleVersion']
  end

  # verison is the bundle short version eg. 3.6
  def version
    @info['CFBundleShortVersionString']
  end

  def full_version
    "#{version}(#{build})"
  end



  ############ embedded.mobileprovision ############

  def provision

    cmd = "security cms -D -i \"#{provision_path}\""
    begin
      @provision ||= CFPropertyList.native_types(CFPropertyList::List.new(data: `#{cmd}`).value)
    rescue CFFormateError
      @provision = {}
    end
  end

  def has_provision?
    File.file? provision_path
  end

  def provision_path
    @provision_path = File.join(@path, 'embedded.mobileprovision')
  end

  def devices
    @provision['ProvisionedDevices']
  end

  def provision_name
    @provision['Name']
  end

  def provision_team_name
    @provision['TeamName']
  end


end
