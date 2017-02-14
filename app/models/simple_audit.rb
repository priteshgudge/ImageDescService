

class SimpleAudit
    attr_accessor :audit_source
    attr_accessor :title
    attr_accessor :changed_by
    # Ordered array of name/value pairs that can be extracted 
    attr_accessor :meta_data

    def initialize
       self.meta_data = []
    end
end