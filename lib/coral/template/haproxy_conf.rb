
module Coral
module Template
class HAProxyConf < Plugin::Template
  
  #-----------------------------------------------------------------------------
  # Renderers  
   
  def render_processed(input)
    output = ''
        
    case input      
    when Hash
      [ 'global', 'defaults' ].each do |special|
        unless Util::Data.empty?(input[special])
          output << render_section(special, '', input[special])
          input.delete(special)
        end
      end
      
      input.each do |type, collection|
        if collection.is_a?(Hash)
          collection.each do |name, data|
            output << render_section(type, name, data)
          end
        end
      end
    end              
    return output     
  end
  
  #-----------------------------------------------------------------------------
    
  def render_section(type, name, input)
    output = ''
    if input.is_a?(Hash)       
      output << "#{type} #{name}\n"
 
      input.each do |keyword, data|
        output << render_attribute(keyword, data)
      end
    end  
    return "#{output}\n" 
  end
    
  #-----------------------------------------------------------------------------
    
  def render_attribute(keyword, data)
    output     = ''
    parameters = []
    
    unless Util::Data.undef?(data)
      case data
      when Hash
        data.each do |name, item|
          output << render_attribute([ keyword, name ].flatten, item)
        end  
        
      when Array      
        data.each do |item|
          parameters << item
        end     
      
      when String
        parameters = [ data ] 
      end
      
      unless keyword.is_a?(Array)
        keyword = [ keyword ]
      end
    
      unless data.is_a?(Hash)
        output << '  ' + keyword.join(' ') + ' ' + parameters.join(' ') + "\n"
      end
    end    
    return output
  end   
end
end
end