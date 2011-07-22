module Zergio
  class ObjectBase

    # Attributes shared by all objects.
    attr_writer :id, :created_at, :updated_at

    def id
      if valid_id?
        @id
      else
        @id = (@id.to_s.scan(/^(\d+)$/).first.first rescue nil)
      end
    end

    def as_time(input)
      input.kind_of?(Time) ? input : DateTime.parse(input.to_s).to_time
    end

    def created_at
      as_time(@created_at)
    end

    def updated_at
      as_time(@created_at)
    end

    def set_connection(conn)
      @connection = (conn.respond_to?(:spawn)) ? conn : nil
    end
  end
end
