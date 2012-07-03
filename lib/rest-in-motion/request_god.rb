class RequestGod
  attr_accessor :base_URL, :regular_requests, :resource_requests

  # singleton
  def self.instance(*args)
    if args.count == 1
      @@instance ||= new args[0]
    else
      @@instance ||= new
    end
  end

  def initialize(base_URL)
    @regular_requests = []
    @resource_requests = []
    @base_URL = base_URL
    RKClient.clientWithBaseURLString base_URL
    self
  end

  def base_URL=(base_URL)
    @base_URL = base_URL
    RKClient.clientWithBaseURLString base_URL
  end

  def RegularRequest(path, method:method, delegate:delegate)
    @regular_requests << RegularRequest.new(@regular_requests.count, path, method, delegate)
    @regular_requests.last
  end

  def ResourceRequest(path, method:method, delegate:delegate)
    @resource_requests << ResourceRequest.new(@resource_requests.count, path, method, delegate)
    @resource_requests.last
  end
end
