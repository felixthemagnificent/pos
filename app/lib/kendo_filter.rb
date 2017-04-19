module KendoFilter
  @table_name = ''

  def self.filter_grid(params, model,  type = {}, custom_fields = {}, order = :desc, custom_sorting = {}, enum_sorting = {}, table_name = '')
    @table_name = table_name
    filter = params[:filter]
    sort = params[:sort]
    raise "Fill 'type' array" if type.blank?
    result = parse_array(filter, custom_fields, type) unless filter.blank?
    field, direction = parse_sort(sort) unless sort.blank? || sort.empty?
    model = model.where(result)

    if field.blank? || direction.blank?
      model = model.order('created_at' => order)
    elsif custom_sorting.has_key? field.to_sym
      model = model.order("#{custom_sorting[field.to_sym]} #{direction}")
    elsif enum_sorting.has_key? field.to_sym
      model = sort_by_enum_field(model, field, enum_sorting[field.to_sym], direction)
    else
      model = model.order(field.to_sym => direction)
    end
    total = model.count
    unless params[:take].nil? || params[:skip].nil?
      model = model.offset(params[:skip]).limit(params[:take])
    end
    return model, total
  end

  def self.sort_by_enum_field model, field, values_set, direction
    if direction == :desc
      set = values_set.sort.reverse.to_h
    else
      set = values_set.sort.to_h
    end
    batches = []
    set.each do |k, v|
      batches << model.where(field => v)
    end
    model = batches.first
    batches.each do |b|
      model = model.union(b)
    end
    return model
  end

  def self.array_compare(first = [], second = [])
    if (first - second).count == 0
      true
    else
      false
    end
  end

  def self.filter(params, model, type)
    filter = params[:filter]
    unless filter.blank?
      result = parse_array(filter, {}, type)
      model = model.where(result)
    end
    return model
  end

  def self.parse_sort(sort_array)
    return sort_array['0'][:field], sort_array['0'][:dir]
  end

  def self.parse_array(filter_array, custom_fields, type)
    single_field = %w(field value operator)

    if array_compare(filter_array.keys, single_field) # simple filter
      return parse_field(filter_array, custom_fields, type)
    else # array of filters
      logic = filter_array[:logic]
      filters = filter_array[:filters]
      filter_result = []
      filters.each_value { |val|
        filter_result.push(parse_array(val, custom_fields, type))
      } unless filters.blank?
      if filter_result.blank?
        return 'TRUE'
      else
        return '(' + filter_result.join(" #{logic} ") + ')' unless filter_result.blank?
      end
    end
  end

  def self.parse_field(field_hash, custom_fields, type)
    field = field_hash['field'].gsub(/[^0-9A-Za-z_]/, '')
    if custom_fields.keys.include? field.to_sym
      return custom_fields[field.to_sym].call field_hash['value']
    else
      operator = field_hash['operator']
      type = type[field.to_sym]
      field = @table_name.blank? ? "`#{field}`" : "`#{@table_name}`.`#{field}`"
      value = field_hash['value'].to_s
      case type
      when 'string'
        return parse_string(field, value, operator)
      when 'numeric'
        return parse_numeric(field, value, operator)
      when 'date'
        return parse_date(field, value, operator)
      when 'datetime'
        return parse_datetime(field, value, operator)
      else
        raise "Illegal type name for field #{field}"
      end
    end
  end

  def self.parse_numeric(field, value, operator)
    value = value.to_i
    case operator
    when 'gte'
      operator = '>='
    when 'gt'
      operator = '>'
    when 'lte'
      operator = '<='
    when 'lt'
      operator = '<'
    when 'eq'
      operator = '='
    else
      raise "Check `types` hash for field #{field}"
    end
    return "( #{field} #{operator} #{value} )"
  end

  def self.parse_string(field, value, operator)
    case operator
    when 'contains'
      operator = 'LIKE'
      value = ActiveRecord::Base::sanitize("%#{value}%")
    when 'neq'
      operator = '<>'
      value = ActiveRecord::Base::sanitize("#{value}")
    when 'not_contains'
      operator = 'NOT LIKE'
      value = ActiveRecord::Base::sanitize("%#{value}%")
    when 'eq'
      operator = '='
      value = ActiveRecord::Base::sanitize("#{value}")
    else
      raise "Check `types` hash for field #{field}"
    end
    return "( #{field} #{operator} #{value} )"
  end

  def self.parse_date(field, value, operator)
    case operator
    when 'gte'
      operator = '>='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y')"
    when 'gt'
      operator = '>'
      value = "STR_TO_DATE('#{value}','%a %b %d %Y')"
    when 'lte'
      operator = '<='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y')"
    when 'lt'
      operator = '<'
      value = "STR_TO_DATE('#{value}','%a %b %d %Y')"
    when 'eq'
      operator = '='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y')"
      return "(#{field} >= #{value} AND #{field} < ADDDATE(#{value},1))"
    else
      raise "Check `types` hash for field #{field}"
    end
    return "( #{field} #{operator} #{value} )"
  end

  def self.parse_datetime(field, value, operator)
    case operator
    when 'gte'
      operator = '>='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y %T')"
    when 'gt'
      operator = '>'
      value = "STR_TO_DATE('#{value}','%a %b %d %Y %T')"
    when 'lte'
      operator = '<='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y %T')"
    when 'lt'
      operator = '<'
      value = "STR_TO_DATE('#{value}','%a %b %d %Y %T')"
    when 'eq'
      operator = '='
      value = "STR_TO_DATE('#{value}','%a %b %d %Y %T')"
    else
      raise "Check `types` hash for field #{field}"
    end
    return "( #{field} #{operator} #{value} )"
  end
end