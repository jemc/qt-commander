
module Qt::Commander::Creator
  class Profile < InfoObject
    
    key :name,            'PE.Profile.Name'
    key :id,              'PE.Profile.Id'
    key :autodetected,    'PE.Profile.AutoDetected'
    key :device,         ['PE.Profile.Data', 'PE.Profile.Device']
    key :type,           ['PE.Profile.Data', 'PE.Profile.DeviceType']
    key :sysroot,        ['PE.Profile.Data', 'PE.Profile.SysRoot']
    key :toolchain,      ['PE.Profile.Data', 'PE.Profile.ToolChain']
    key :version,        ['PE.Profile.Data', 'QtSupport.QtInformation']
    
    def initialize info
      super
      
      @toolchain = Qt::Commander::Creator.toolchains.detect do |tc|
        tc.id == @toolchain
      end
      
      @version   = Qt::Commander::Creator.versions.detect do |tc|
        tc.id == @version || tc.autodetect_src == @version
      end
    end
    
    def android?
      type =~ /Android/
    end
    
  end
end
