module Zergio
  class ObjectCollection
    attr_accessor_with_default :items, Hash.new
    attr_accessor_with_default :sync, true
    
    attr_accessor :klass, :owner, :connection, :loaded, :dirty, :sync
    
    def list
    end
    
    def count
    end

    def fetch(name)
    end
    
  end
end
