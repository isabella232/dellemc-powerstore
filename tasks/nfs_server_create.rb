#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
require 'json'
require 'puppet'
require 'openssl'
# require 'pry-remote'; binding.remote_pry
    
class PowerstoreNfsServerCreateTask < TaskHelper

  def task(arg_hash)

    header_params = {}
    
    # params=args[0][1..-1].split(',')

    # arg_hash={}
    # params.each { |param|
    #   mapValues= param.split(':',2)
    #   if mapValues[1].include?(';')
    #       mapValues[1].gsub! ';',','
    #   end
    #   arg_hash[mapValues[0][1..-2]]=mapValues[1][1..-2]
    # }

    # Remove task name from arguments - should contain all necessary parameters for URI
    arg_hash.delete('_task')
    operation_verb = 'Post'
    operation_path = '/nfs_server'
    parent_consumes = 'application/json'
    query_params, body_params, path_params = format_params(arg_hash)

    header_params = {}

    result = transport.call_op(path_params, query_params, header_params, body_params, operation_path, operation_verb, parent_consumes)

    if result.is_a? Net::HTTPSuccess
      if result.body.nil?
        return nil
      end
      body = JSON.parse(result.body)
      if body.class == Array
        return { "list" => body }
      else
        return body
      end
    else
      raise result.body
    end
  end

  def op_param(name, location, paramalias, namesnake)
    { :name => name, :location => location, :paramalias => paramalias, :namesnake => namesnake }
  end
  
  def format_params(key_values)
    query_params = {}
    body_params = {}
    path_params = {}

    key_values.each { | key, value |
      if value.respond_to?(:include) and value.include?("=>")
        value.include?("=>")
        Puppet.debug("Running hash from string on #{value}")
        value.gsub!("=>",":")
        value.gsub!("'","\"")
        key_values[key] = JSON.parse(value)
        Puppet.debug("Obtained hash #{key_values[key].inspect}")
      end
    }


    if key_values.key?('body')
      if File.file?(key_values['body'])
        if key_values['body'].include?('json')
          body_params['file_content'] = File.read(key_values['body'])
        else
          body_params['file_content'] =JSON.pretty_generate(YAML.load_file(key_values['body']))
        end
      end
    end

    op_params = [
      op_param('credentials_cache_TTL', 'body', 'credentials_cache_ttl', 'credentials_cache_ttl'),
      op_param('host_name', 'body', 'host_name', 'host_name'),
      op_param('is_extended_credentials_enabled', 'body', 'is_extended_credentials_enabled', 'is_extended_credentials_enabled'),
      op_param('is_nfsv3_enabled', 'body', 'is_nfsv3_enabled', 'is_nfsv3_enabled'),
      op_param('is_nfsv4_enabled', 'body', 'is_nfsv4_enabled', 'is_nfsv4_enabled'),
      op_param('is_secure_enabled', 'body', 'is_secure_enabled', 'is_secure_enabled'),
      op_param('is_use_smb_config_enabled', 'body', 'is_use_smb_config_enabled', 'is_use_smb_config_enabled'),
      op_param('nas_server_id', 'body', 'nas_server_id', 'nas_server_id'),
      ]
    op_params.each do |i|
      location = i[:location]
      name     = i[:name]
      paramalias = i[:paramalias]
      name_snake = i[:namesnake]
      if location == 'query'
        query_params[name] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      elsif location == 'body'
        body_params[name] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      else
        path_params[name_snake.to_sym] = key_values[name_snake.to_sym] unless key_values[name_snake.to_sym].nil?
      end
    end
    
    return query_params,body_params,path_params
  end

  if __FILE__ == $0
    PowerstoreNfsServerCreateTask.run
  end

end