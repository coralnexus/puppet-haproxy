#
# haproxy_firewall.rb
#
# Returns the firewall rules (port / label) needed for a given proxy definition.
#
module Puppet::Parser::Functions
  newfunction(:haproxy_firewall, :type => :rvalue, :doc => <<-EOS
This function returns the firewall rules (port / label) needed for a given proxy definition.
    EOS
) do |args|
    rules = {}
    
    CORL.run do
      raise(Puppet::ParseError, "haproxy_firewall(): Must have a configuration hash (proxies) specified; " +
        "given (#{args.size} for 1)") if args.size < 1
        
      config = args[0]
      label  = ( args.size > 1 ? args[1] : 'INPUT Allow HAProxy connections' )
      
      address_pattern = /^\s*(.+)\s*\:\s*([\d\-]+)\s*$/
      
      parse_attributes = lambda do |data, active|
        data.each do |name, item|
          local_active = active
          inner        = true
          
          if [ 'bind' ].include?(name)
            local_active = true
            inner        = false  
          end
          
          if item.is_a?(Hash)
            parse_attributes.call(item, local_active)                
          
          elsif local_active
            if inner && matches = name.match(address_pattern)
              port        = matches.captures[1]
              rules[port] = {
                'name'  => port + " #{label}",
                'dport' => port
              }  
            end
            
            unless CORL::Util::Data.empty?(item)
              case item
              when String, Symbol, Number
                item = [ item.to_s ]  
              end
            
              item.each do |parameter|
                if matches = parameter.match(address_pattern)
                  port        = matches.captures[1]
                  rules[port] = {
                    'name'  => port + " #{label}",
                    'dport' => port
                  }
                end
              end
            end
          end              
        end        
      end
      
      config.each do |type, collection|
        unless type == 'global' || type == 'defaults'
          if collection.is_a?(Hash)
            parse_attributes.call(collection, false)            
          end
        end
      end
    end
    return rules
  end
end
