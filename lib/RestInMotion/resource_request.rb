class ResourceRequest < RegularRequest
  attr_accessor :root_mapping

  # map resources to objects in code
  def request(request, didLoadResponse:response)
    # assert(@root_mapping.class == Hash, "mappings must be hashes (request root)")

    error = Pointer.new(:object)
    response = RequestResponse.new(response, nil)
    response = NSJSONSerialization.JSONObjectWithData(response.data, options:0, error:error)
    if response.class == Array
      @response = []
      response.each { |item| @response << @root_mapping.deserialize(item) }
    else
      @response = @root_mapping.deserialize(response)
    end

    invoke_callback
  end
end
