module Zerigo
  class Host < ObjectBase

    attr_accessor_with_default :responses, []
    attr_accessor :parent

    def initialize(name, *data, &block)
    end
    alias :create :new
    
    def stats
    end
    
    def update(name, *data, &block)
    end
    
    def delete(n)
    end
end
