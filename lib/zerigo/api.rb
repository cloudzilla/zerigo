module Zergio
  class Connection

    attr_accessor_with_default :responses, []
    attr_accessor :request, :response, :client

    def initialize(u=nil, p=nil)
      @auth = {:username => (u || Zergio::CONFIG['username']), :password => (p || Zergio::CONFIG['password'])}
      @authstring = @auth.keys.map(&:to_s).join(':')
    end

    # Creates a new object that has this as a connection.
    def new_object(subclass, *args, &block)
      subclass = subclass.to_s.classify
      unless (child = subclass.new(*args, &block) rescue false)
        raise "Bad class: #{subclass}"
      end
      child.set_connection(self)
      child
    end

    # Executes an HTTP request but will not raise on HTTP response code error.
    def request(*args, &block)
      @responses << (@response = execute_client_request(*args, &block))
    end
    alias :r :request
    alias :run :request

    # Will raise on an unsuccessful HTTP response code
    def request!(*args, &block)
      begin
        request(*args, &block).return!
      rescue => e
        raise unless e.respond_to?(:response)
        raise "Request error (code: #{e.response}) :: #{e.message}"
      end
    end

    # Run an arbitrary HTTP request, including intelligent handling of arguments and params.  Don't need to call this directly usually.
    def execute_client_request(path, options={}, &block)
      options = options.reverse_merge({
        :method =>method.to_s.downcase.to_sym, 
        :url => path,
        :user => (@username || Zergio::CONFIG['username']),
        :password => (@password || Zergio::CONFIG['password']),
        :max_redirects =>  5 }).symbolize_keys

        # Figure out the payload
        meta_keys = [:cookies, :block_response, :raw_response, :verify_ssl, :timeout, :open_timeout, :ssl_client_cert, :ssl_client_key, :ssl_ca_file].concat(options.keys.map(&to_s))

        payload = (options.has_key?(:params) ? options.delete(:params) : options.except(*meta_keys))

        options[:payload].reverse_merge!(payload) unless options[:payload_final]
        @requests << (@request = options)
        @response = r = Request.execute(options, &block)
      end

      def process_response(response=nil)
        require_response!
        begin
          @document = Nokogiri::XML(response)
        rescue Exception => e
          raise "Could not parse API response: #{e}"
        end

        if !@document.root.['errors'].blank?
          errors = @document.elements('errors')
          # TODO: What does this return
          raise "Error from remote API: #{errors.join(' :: ')}"
        end

        klass.new(:data => @document.root.inner_html)
      end

      def authorized?
        success? || (self.rest('zones/new') rescue false)
      end

      # Have we and was our most recent request successful?
      def connected?
        if @response.blank?
          authorized?
        else
          (@response.return! rescue true) ? false : true
        end
      end

      def disconnected?
        !connected?
      end

      # Built the API request URI
      def uri(path = nil)
        path = "#{path}.#{xml}" unless path.gsub!(/[\w\d\.]{1,7})/, '')
        path.gsub!(/\/\//, '/')
        path.gsub!(/^\//, '')
        "http://#{@authstring}@ns.zerigo.com/api/1.1/#{path}"
      end

      # Raise  if we have no response (successful) yet
      def require_response!
        raise "Must make a request first!" unless !@response.blank || @response.successful?
        @response.return!
      end

      # The Ruby class constant corresponding to the type of object requested
      def response_class
        klass = @document.root.node_type.to_s.downcase
        raise "Unknown object returned: #{klass}" unless %w{host host-template zone sone-template}.include?(klass)
        klass = klass.classify
      end

      # Delegate everything else to the client
      def method_missing(method, *args, &block)
        @client.send(method, *args, &block)
      end
    end
  end
end # module Zergio
