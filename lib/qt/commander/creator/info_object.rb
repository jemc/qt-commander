
module Qt::Commander::Creator
  class InfoObject
    
    def self.key name, orig_name, opts={}
      @keys ||= []
      @keys << [ name, orig_name, opts ]
      attr_reader name
    end
    
    def self.keys
      @keys ||= []
    end
    
    
    def [] key
      instance_variable_get :"@#{key}"
    end
    
    def initialize info
      self.class.keys.each do |name, orig_name, opts|
        orig_name = [orig_name] unless orig_name.is_a? Array
        val = info
        
        orig_name.each do |orig|
          val = val.fetch(orig) if val.key? orig or !opts[:optional]
        end
        
        instance_variable_set :"@#{name}", val unless val == info
      end
    end
    
    
    
  end
end
