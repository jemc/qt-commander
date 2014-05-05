
require 'inifile'
require 'nokogiri'

module Qt::Commander::Creator
  class << self
    attr_reader :config_ini
    attr_reader :config_dir
    
    def config_ini= path
      @config_ini = path
      @ini = IniFile.new File.read path
    end
    
    def config_dir= path
      @config_dir = path
      update_toolchains
      update_profiles
    end
    
    attr_reader :ini
    
    def toolchains *symbols
      @toolchains.select do |info|
        !symbols.detect do |sym|
          !(info[:target].to_s .include?("#{sym}") || 
            info[:name].to_s   .include?("#{sym}") || 
            info[:id].to_s     .include?("#{sym}"))
        end
      end
    end
    
    def toolchain *symbols
      toolchains(*symbols).last
    end
    
    attr_reader :profiles
    
    private
    
    def update_toolchains
      @toolchains = File.read File.join @config_dir, 'toolchains.xml'
      @toolchains = parse_qt_xml(@toolchains).map do |_, info|
        {}.tap { |h|
          %w[
            name                   ProjectExplorer.ToolChain.DisplayName
            id                     ProjectExplorer.ToolChain.Id
            autodetect             ProjectExplorer.ToolChain.Autodetect
            path                   ProjectExplorer.GccToolChain.Path
            supported              ProjectExplorer.GccToolChain.SupportedAbis
            target                 ProjectExplorer.GccToolChain.TargetAbi
            android_ndk_tc_version Qt4ProjectManager.Android.NDK_TC_VERION
          ].each_slice(2).each { |key, oldkey|
            h[key.to_sym] = info[oldkey] if info.key? oldkey
          }
        } if info.is_a? Hash
      end.compact
    end
    
    def update_profiles
      @profiles = File.read File.join @config_dir, 'profiles.xml'
      @profiles = parse_qt_xml(@profiles).map do |_, info|
        {}.tap { |h|
          %w[
            name                   PE.Profile.Name
            id                     PE.Profile.Id
            autodetected           PE.Profile.AutoDetected
            data                   PE.Profile.Data
          ].each_slice(2).each { |key, oldkey|
            h[key.to_sym] = info[oldkey] if info.key? oldkey
          }
          info = h.delete :data
          h.merge!({}.tap { |h|
            %w[
              device               PE.Profile.Device
              type                 PE.Profile.DeviceType
              sysroot              PE.Profile.SysRoot
              toolchain            PE.Profile.ToolChain
            ].each_slice(2).each { |key, oldkey|
              h[key.to_sym] = info[oldkey] if info.key? oldkey
            }
            h[:toolchain] = toolchain h[:toolchain] if h[:toolchain]
          }) if info
        } if info.is_a? Hash
      end.compact
      
      pp @profiles
    end
    
    def parse_qt_xml string
      from_value = from_valuelist = from_valuemap = nil
      
      from_node = Proc.new do |node|
        case node.name
        when "value";     from_value    .call node
        when "valuelist"; from_valuelist.call node
        when "valuemap";  from_valuemap .call node
        else; raise NotImplementedError, "name == #{node.name.inspect}"
        end
      end
      
      from_value = Proc.new do |node|
        text = node.children.first.to_s
        
        case node['type']
        when 'int';        Integer(text)
        when 'bool';       text=='true'
        when 'QString';    text
        when 'QByteArray'; text
        else; raise NotImplementedError, "['type'] == #{node['type'].inspect}"
        end
      end
      
      from_valuelist = Proc.new do |node|
        node.children
        .reject{ |node| node.is_a? Nokogiri::XML::Text }
        .each_with_object([]) do |node, ary|
          ary.push from_node.call node
        end
      end
      
      from_valuemap = Proc.new do |node|
        node.children
        .reject{ |node| node.is_a? Nokogiri::XML::Text }
        .each_with_object({}) do |node, h|
          h[node['key']] = from_node.call node
        end
      end
      
      Nokogiri::XML.parse(string)
      .xpath('//data')
      .each_with_object({}) do |node,h|
        key, val = node.children.reject{ |node| node.is_a? Nokogiri::XML::Text }
        
        key = key.children.first.to_s
        val = from_node.call val
        
        h[key] = val if key and val
      end
    end
  end
  
  self.config_dir = File.join Dir.home, ".config/QtProject/qtcreator"
  self.config_ini = File.join Dir.home, ".config/QtProject/QtCreator.ini"
  
end
