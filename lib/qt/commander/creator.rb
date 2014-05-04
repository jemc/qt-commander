
require 'inifile'
require 'nokogiri'

module Qt::Commander::Creator
  class << self
    attr_reader :config_dir
    attr_reader :config_ini
    
    attr_reader :ini
    
    def config_dir= path
      @config_dir = path
      update_toolchains
    end
    
    def config_ini= path
      @config_ini = path
      @ini = IniFile.new File.read path
    end
    
    def toolchains *symbols
      @toolchains.select do |info|
        !symbols.detect do |sym|
          !(info[:target].to_s .include?("#{sym}") || 
            info[:name].to_s   .include?("#{sym}"))
        end
      end
    end
    
    def toolchain *symbols
      toolchains(*symbols).last
    end
    
    private
    
    def update_toolchains
      @toolchains = File.read File.join @config_dir, 'toolchains.xml'
      @toolchains = parse_qt_xml(@toolchains).map do |_, info|
        if info.is_a? Hash
          {
            name:       info["ProjectExplorer.ToolChain.DisplayName"],
            id:         info["ProjectExplorer.ToolChain.Id"],
            autodetect: info["ProjectExplorer.ToolChain.Autodetect"],
            path:       info["ProjectExplorer.GccToolChain.Path"],
            supported:  info["ProjectExplorer.GccToolChain.SupportedAbis"],
            target:     info["ProjectExplorer.GccToolChain.TargetAbi"],
          }
        end
      end.compact
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
        when 'int';     Integer(text)
        when 'bool';    text=='true'
        when 'QString'; text
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
