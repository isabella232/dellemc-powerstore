require 'puppet/resource_api'
require "pry"

class Puppet::Provider::PowerstoreSmbShare::PowerstoreSmbShare
  def canonicalize(context, resources)
    #nout to do here but seems we need to implement it
    resources
  end

  def get(context)
context.debug("Entered get")
      hash = self.class.fetch_all_as_hash(context)
      context.debug("Completed get, returning hash #{hash}")
      hash

  end

  def set(context, changes, noop: false)
    context.debug("Entered set")


    changes.each do |name, change|
      context.debug("set change with #{name} and #{change}")
      #FIXME: key[:name] below hardwires the unique key of the resource to be :name
      is = change.key?(:is) ? change[:is] : get(context).find { |key| key[:name] == name }
      should = change[:should]

      is = { name: name, ensure: 'absent' } if is.nil?
      should = { name: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        create(context, name, should) unless noop
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          # FIXME hardwired
          should[:id] = is[:id]
          delete(context, should) unless noop
        end
      elsif is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'absent'
        context.failed(name, message: 'Unexpected absent to absent change')
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
          # FIXME hardwired
          # should[:id] = is[:id]
        update(context, name, should)
      end
    end
  end

  def create(context, name, should)
    context.creating(name) do
      new_hash = build_create_hash(should)
      new_hash.delete("id")
      response = self.class.invoke_create(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info("Added :ensure to property hash")
      else
        raise("Create failed.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during create. The state of the resource is unknown.  ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def update(context, name, should)
    context.updating(name) do
      new_hash = build_update_hash(should)
      new_hash.delete("id")
      response = self.class.invoke_update(context, should, new_hash)

      if response.is_a? Net::HTTPSuccess
        should[:ensure] = 'present'
        Puppet.info("Added :ensure to property hash")
      else
        raise("Flush failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
      end
    end
  rescue Exception => ex
    Puppet.alert("Exception during flush. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_create_hash(resource)
    smb_share = {}
    smb_share["description"] = resource[:description] unless resource[:description].nil?
    smb_share["file_system_id"] = resource[:file_system_id] unless resource[:file_system_id].nil?
    smb_share["is_ABE_enabled"] = resource[:is_abe_enabled] unless resource[:is_abe_enabled].nil?
    smb_share["is_branch_cache_enabled"] = resource[:is_branch_cache_enabled] unless resource[:is_branch_cache_enabled].nil?
    smb_share["is_continuous_availability_enabled"] = resource[:is_continuous_availability_enabled] unless resource[:is_continuous_availability_enabled].nil?
    smb_share["is_encryption_enabled"] = resource[:is_encryption_enabled] unless resource[:is_encryption_enabled].nil?
    smb_share["name"] = resource[:name] unless resource[:name].nil?
    smb_share["offline_availability"] = resource[:offline_availability] unless resource[:offline_availability].nil?
    smb_share["path"] = resource[:path] unless resource[:path].nil?
    smb_share["umask"] = resource[:umask] unless resource[:umask].nil?
    return smb_share
  end

  def build_update_hash(resource)
    smb_share = {}
    smb_share["description"] = resource[:description] unless resource[:description].nil?
    smb_share["is_ABE_enabled"] = resource[:is_abe_enabled] unless resource[:is_abe_enabled].nil?
    smb_share["is_branch_cache_enabled"] = resource[:is_branch_cache_enabled] unless resource[:is_branch_cache_enabled].nil?
    smb_share["is_continuous_availability_enabled"] = resource[:is_continuous_availability_enabled] unless resource[:is_continuous_availability_enabled].nil?
    smb_share["is_encryption_enabled"] = resource[:is_encryption_enabled] unless resource[:is_encryption_enabled].nil?
    smb_share["offline_availability"] = resource[:offline_availability] unless resource[:offline_availability].nil?
    smb_share["umask"] = resource[:umask] unless resource[:umask].nil?
    return smb_share
  end

  def build_delete_hash(resource)
    smb_share = {}
    return smb_share
  end

  def build_hash(resource)
    smb_share = {}
    smb_share["description"] = resource[:description] unless resource[:description].nil?
    smb_share["file_system_id"] = resource[:file_system_id] unless resource[:file_system_id].nil?
    smb_share["id"] = resource[:id] unless resource[:id].nil?
    smb_share["is_ABE_enabled"] = resource[:is_abe_enabled] unless resource[:is_abe_enabled].nil?
    smb_share["is_branch_cache_enabled"] = resource[:is_branch_cache_enabled] unless resource[:is_branch_cache_enabled].nil?
    smb_share["is_continuous_availability_enabled"] = resource[:is_continuous_availability_enabled] unless resource[:is_continuous_availability_enabled].nil?
    smb_share["is_encryption_enabled"] = resource[:is_encryption_enabled] unless resource[:is_encryption_enabled].nil?
    smb_share["name"] = resource[:name] unless resource[:name].nil?
    smb_share["offline_availability"] = resource[:offline_availability] unless resource[:offline_availability].nil?
    smb_share["offline_availability_l10n"] = resource[:offline_availability_l10n] unless resource[:offline_availability_l10n].nil?
    smb_share["path"] = resource[:path] unless resource[:path].nil?
    smb_share["umask"] = resource[:umask] unless resource[:umask].nil?
    return smb_share
  end

  def self.build_key_values
    key_values = {}
    
    key_values["api-version"] = "assets"
    key_values
  end

  # def destroy(context)
  #   delete(context, resource)
  # end

  def delete(context, should)
    new_hash = build_delete_hash(should)
    response = self.class.invoke_delete(context, should, new_hash)
    if response.is_a? Net::HTTPSuccess
      should[:ensure] = 'absent'
      Puppet.info "Added 'absent' to property_hash"
    else
      raise("Delete failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}")
    end
  rescue Exception => ex
    Puppet.alert("Exception during destroy. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end


  def self.invoke_list_all(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation smb_shareCollectionQuery")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/smb_share', 'Get','application/json')
  end


  def self.invoke_create(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation smb_shareCreate")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('body', 'body', 'body', 'body'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/smb_share', 'Post','application/json')
  end


  def self.invoke_update(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation smb_shareModify")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('body', 'body', 'body', 'body'),
      self.op_param('id', 'path', 'id', 'id'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/smb_share/%{id}', 'Patch','application/json')
  end


  def self.invoke_delete(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation smb_shareDelete")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('id', 'path', 'id', 'id'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/smb_share/%{id}', 'Delete','application/json')
  end




  def self.invoke_get_one(context, resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation smb_shareInstanceQuery")
    path_params = {}
    query_params = {}
    header_params = {}
    header_params["User-Agent"] = ""
    
    op_params = [
      self.op_param('id', 'path', 'id', 'id'),
    ]
    op_params.each do |i|
      inquery = i[:inquery]
      name    = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if inquery == 'query'
        query_params[name] = key_values[name] unless key_values[name].nil?
        query_params[name] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        query_params[name] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name] unless key_values[name].nil?
        path_params[name_snake.to_sym] = ENV["powerstore_#{name_snake}"] unless ENV["powerstore_#{name_snake}"].nil?
        path_params[name_snake.to_sym] = resource[paramalias.to_sym] unless resource.nil? || resource[paramalias.to_sym].nil?
      end
    end
    context.transport.call_op(path_params, query_params, header_params, body_params, '/smb_share/%{id}', 'Get','application/json')
  end


  def self.fetch_all_as_hash(context)
    items = self.fetch_all(context)
    if items
      items.collect do |item|
        hash = {

          description: item['description'],
          file_system_id: item['file_system_id'],
          id: item['id'],
          is_abe_enabled: item['is_ABE_enabled'],
          is_branch_cache_enabled: item['is_branch_cache_enabled'],
          is_continuous_availability_enabled: item['is_continuous_availability_enabled'],
          is_encryption_enabled: item['is_encryption_enabled'],
          name: item['name'],
          offline_availability: item['offline_availability'],
          offline_availability_l10n: item['offline_availability_l10n'],
          path: item['path'],
          umask: item['umask'],
          ensure: 'present',
        }


        self.deep_delete(hash, [:is_abe_enabled])
        self.deep_delete(hash, [:is_branch_cache_enabled])
        self.deep_delete(hash, [:is_continuous_availability_enabled])
        self.deep_delete(hash, [:is_encryption_enabled])
        self.deep_delete(hash, [:offline_availability])
        self.deep_delete(hash, [:umask])
        Puppet.debug("Adding to collection: #{item}")

        hash

      end.compact
    else
      []
    end
  rescue Exception => ex
    Puppet.alert("ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def self.deep_delete(hash_item, tokens)
    if tokens.size == 1
      if hash_item.kind_of?(Array)
        hash_item.map! { |item| deep_delete(item, tokens) }
      else
        hash_item.delete(tokens[0]) unless hash_item.nil? or hash_item[tokens[0]].nil?
      end
    else
      if hash_item.kind_of?(Array)
        hash_item.map! { |item| deep_delete(item, tokens[1..-1]) }
      else
        hash_item[tokens.first] = deep_delete(hash_item[tokens.first], tokens[1..-1]) unless hash_item.nil? or hash_item[tokens[0]].nil?
      end
    end
    return hash_item
  end

  def self.fetch_all(context)
    response = invoke_list_all(context)
    if response.kind_of? Net::HTTPSuccess
      body = JSON.parse(response.body)
      if body.is_a? Array # and body.key? "value"
        return body #["value"]
      end
    end
  end


  def self.authenticate(path_params, query_params, header_params, body_params)
    return true
  end


  def exists?
    return_value = @property_hash[:ensure] && @property_hash[:ensure] != 'absent'
    Puppet.info("Checking if resource #{name} of type <no value> exists, returning #{return_value}")
    return_value
  end

  def self.add_keys_to_request(request, hash)
    if hash
      hash.each { |x, v| request[x] = v }
    end
  end

  def self.to_query(hash)
    if hash
      return_value = hash.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
      if !return_value.nil?
        return return_value
      end
    end
    return ""
  end

  def self.op_param(name, inquery, paramalias, namesnake)
    operation_param = { :name => name, :inquery => inquery, :paramalias => paramalias, :namesnake => namesnake }
    return operation_param
  end


end
