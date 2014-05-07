
module Qt::Commander::Creator
  class Toolchain < InfoObject
    
    key :name,                   'ProjectExplorer.ToolChain.DisplayName'
    key :id,                     'ProjectExplorer.ToolChain.Id'
    key :autodetect,             'ProjectExplorer.ToolChain.Autodetect'
    key :path,                   'ProjectExplorer.GccToolChain.Path'
    key :supported,              'ProjectExplorer.GccToolChain.SupportedAbis'
    key :target,                 'ProjectExplorer.GccToolChain.TargetAbi'
    
    key :android_ndk_tc_version, 'Qt4ProjectManager.Android.NDK_TC_VERION', optional:true
    
    def android?
      target =~ /android/
    end
    
    def env
      if android?
        envs = {
          'TOOLCHAIN_PATH' => File.dirname(@path),
          'TOOLCHAIN_HOST' => File.basename(@path.gsub(/-gcc$/, '')),
          'TOOLCHAIN_NAME' => File.basename(@path.gsub(/-gcc$/, '-'+@android_ndk_tc_version)),
        }
        
        envs['ANDROID_NDK_ROOT'] = ndk_root = \
          Qt::Commander::Creator.ini['AndroidConfigurations']['NDKLocation']
        
        sep = File::SEPARATOR
        tc_path = @path.scan(/#{ndk_root}#{sep}toolchains#{sep}.*?(?=#{sep})/)
        config_mk = File.read(File.join(tc_path, "config.mk"))
        
        config_mk =~ /TOOLCHAIN_ARCH\s*\:\=\s*(.*)/
        envs['TOOLCHAIN_ARCH'] = $1
        
        config_mk =~ /TOOLCHAIN_ABIS\s*\:\=\s*(.*)/
        envs['TOOLCHAIN_ABIS'] = $1
        
      else
        raise NotImplementedError
      end
      
      envs.keys.each { |key| envs[key], ENV[key] = ENV[key], envs[key] }
      yield if block_given?
      envs.keys.each { |key| envs[key], ENV[key] = ENV[key], envs[key] }
      
      return envs
    end
    
  end
end
 