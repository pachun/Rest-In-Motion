class RequestResponse
  attr_accessor :data, :str, :errors

  def initialize(rkresponse, errors)
    @data = rkresponse.body unless rkresponse.nil?
    @str = rkresponse.bodyAsString unless rkresponse.nil?
    @errors = errors
  end
end
