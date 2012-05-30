class ObjectMapping
  attr_accessor :object_type, :mappings, :sub_mappings

  def initialize(object_type)
    @object_type = object_type
    @mappings = Hash[]
    @sub_mappings = Hash[]
  end

  def serialize(item)
    result = Hash[]
    @mappings.each_value do |leaf|

      if item.instance_variable_get("@#{leaf}").class == Array

        result[leaf] = []
        item.instance_variable_get("@#{leaf}").each do |leaf_item|
          if @sub_mappings.has_key? leaf
            result[leaf] << @sub_mappings[leaf].serialize( item.instance_variable_get("@#{leaf}")[leaf_item] )
          else
            result[leaf] << item.instance_variable_get("@#{leaf}")[leaf_item]
          end
        end

      else

        if @sub_mappings.has_key? leaf
          result[leaf] = @sub_mappings[leaf].serialize( item.instance_variable_get("@#{leaf}") )
        else
          result[leaf] = item.instance_variable_get("@#{leaf}")
        end

      end
    end

    result
  end

  def deserialize(json)
    result = @object_type.new

    json_keys_intersect = mappings.keys & json.keys
    json_keys_intersect.each do |key|
      if @sub_mappings.has_key? @mappings[key]

        if json[key].class == Array
          result.instance_variable_set("@#{@mappings[key]}", [])
          # append them here...
          json[key].each do |current|
            result.instance_variable_set("@#{@mappings[key]}", result.instance_variable_get("@#{@mappings[key]}") << @sub_mappings[@mappings[key]].deserialize(current) )
          end
        else
          result.instance_variable_set("@#{@mappings[key]}", @sub_mappings[@mappings[key]].deserialize(json[key]) )
        end

      else

        if json[key].class == Array
          result.instance_variable_set("@#{@mappings[key]}", [])
          # append them here...
          json[key].each do |current|
            result.instance_variable_set("@#{@mappings[key]}", result.instance_variable_get("@#{@mappings[key]}") << current )
          end
        else
          result.instance_variable_set("@#{@mappings[key]}", json[key])
        end

      end
    end

    result
  end
end
