
require 'inifile'
require 'nokogiri'

require_relative 'creator/info_object'
require_relative 'creator/toolchain'
require_relative 'creator/version'
require_relative 'creator/profile'

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
      
      update_collection :toolchains, Toolchain, 'toolchains.xml'
      update_collection :versions,   Version,   'qtversion.xml'
      update_collection :profiles,   Profile,   'profiles.xml'
    end
    
    attr_reader :ini
    
    attr_reader :toolchains
    attr_reader :versions
    attr_reader :profiles
    
  private
    
    def update_collection ivar, kls, file
      val = File.read File.join @config_dir, file
      val = parse_qt_xml(val).map do |_, info|
        kls.new(info) if info.is_a? Hash
      end.compact
      instance_variable_set :"@#{ivar}", val
    end
    
    def parse_qt_xml string
      from_value = from_valuelist = from_valuemap = nil
      
      from_node = Proc.new do |node|
        case node.name
        when 'value';     from_value    .call node
        when 'valuelist'; from_valuelist.call node
        when 'valuemap';  from_valuemap .call node
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
      
      Nokogiri::XML.parse(string).xpath('//data')
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
