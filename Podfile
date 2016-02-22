# This podfile is intended for development and testing on Snowplow.
#
# If you are working on Snowplow, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.

source 'https://github.com/CocoaPods/Specs.git'

target :lib, :exclusive => true do
  platform :ios, '7.0'
  link_with ['Snowplow']
  pod 'FMDB', '2.5'
  pod 'Reachability', '3.2'
end

target :specs, :exclusive => true do
  platform :ios, '7.0'
  link_with ['SnowplowTests']
  pod 'Nocilla'
  pod 'SnowplowIgluClient'
end

target 'Snowplow-OSX' do
    platform :osx, '10.9'
    pod 'FMDB', '2.5'
end

target 'Snowplow-OSXTests' do
  platform :osx, '10.9'
  pod 'Nocilla'
  pod 'SnowplowIgluClient'
end

post_install do |installer|
  if Gem::Version.new(Gem.loaded_specs['cocoapods'].version) >= Gem::Version.new('0.38.0')
    install_38 installer
  else
    install_37 installer
  end
end

def install_38 installer
  # We need to remove sqlite3 from the library
  # For details see: https://github.com/CocoaPods/CocoaPods/issues/830
  default_library = installer.aggregate_targets.detect { |i| i.target_definition.name == :lib }
  [default_library.xcconfig_relative_path('Debug'), default_library.xcconfig_relative_path('Release')].each do |path|
    path = File.expand_path(File.join(File.dirname(__FILE__), path))
    File.open("config.tmp", "w") do |io|
      f = File.read(path)
      f.gsub!(/-l"sqlite3"/, '')
      io << f
    end
    FileUtils.mv("config.tmp", path)
  end

  # We need to add sqlite3 into the test suite
  default_library = installer.aggregate_targets.detect { |i| i.target_definition.name == :specs }
  [default_library.xcconfig_relative_path('Debug'), default_library.xcconfig_relative_path('Release')].each do |path|
    path = File.expand_path(File.join(File.dirname(__FILE__), path))
    File.open("config.tmp", "w") do |io|
      f = File.read(path)
      f.gsub!(/(OTHER_LDFLAGS =)/, '\1 -l"sqlite3"')
      io << f
    end
    FileUtils.mv("config.tmp", path)
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end

def install_37 installer
  # We need to remove sqlite3 from the library
  # For details see: https://github.com/CocoaPods/CocoaPods/issues/830
  default_library = installer.libraries.detect { |i| i.target_definition.name == :lib }
  [default_library.library.xcconfig_path('Debug'), default_library.library.xcconfig_path('Release')].each do |path|
    File.open("config.tmp", "w") do |io|
      f = File.read(path)
      f.gsub!(/-l"sqlite3"/, '')
      io << f
    end
    FileUtils.mv("config.tmp", path)
  end

  # We need to add sqlite3 into the test suite
  default_library = installer.libraries.detect { |i| i.target_definition.name == :specs }
  [default_library.library.xcconfig_path('Debug'), default_library.library.xcconfig_path('Release')].each do |path|
    File.open("config.tmp", "w") do |io|
      f = File.read(path)
      f.gsub!(/(OTHER_LDFLAGS =)/, '\1 -l"sqlite3"')
      io << f
    end
    FileUtils.mv("config.tmp", path)
  end

  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
