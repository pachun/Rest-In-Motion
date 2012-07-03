GET    = 0
POST   = 1
PUT    = 2
DELETE = 3

class RegularRequest
  attr_reader :id
  attr_accessor :method, :path, :headers, :params, :delegate, :callback, :response

  def initialize(id, path, method, delegate)
    @id = id
    @path = path
    @method = method
    @delegate = delegate
    self
  end

  # send request
  def send
    # assert(@headers.class == Hash, "Headers must be a hash") unless @headers.nil?
    # assert(@params.class == Hash, "Post parameters must be a hash") unless @params.nil?
    case @method
    when GET
      RKClient.sharedClient.get(@path, delegate:self)
    when POST
      RKClient.sharedClient.post(@path, params:@params, delegate:self)
    when PUT
      RKClient.sharedClient.put(@path, params:@params, delegate:self)
    when DELETE
      RKClient.sharedClient.get(@path, delegate:self)
    else
      puts "ERROR: undefined HTTP method #{@method} is not GET, POST, PUT, or DELETE"
    end
  end

  # receive request results
  def request(request, didLoadResponse:response)
    @response = RequestResponse.new(response, nil)
    invoke_callback
  end

  def request(request, didFailWithError:error)
    @response = RequestResponse.new(nil, error.domain)
    invoke_callback
  end

  # inform delegate
  def invoke_callback
    if @callback.nil?
      @delegate.received(@response, id:@id)
    else
      @delegate.send(@callback, @response)
    end
  end
end

