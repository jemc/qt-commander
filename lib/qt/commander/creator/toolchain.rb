
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
    
  end
end
 