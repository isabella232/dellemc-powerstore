require 'spec_helper_acceptance'

describe 'powerstore_remote_system' do
  it 'get remote_system' do
    result = run_resource('powerstore_remote_system')
    expect(result).to match(%r{ensure => 'present'}).or match(%r{Completed get, returning hash \[\]})
  end

  it 'create remote_system' do
    pp = run_resource('powerstore_remote_system', 'string', false)
    pp.gsub!("string", "string_1")
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end

  
  it 'update remote_system' do
    pp = run_resource('powerstore_remote_system', 'string', false)
    pp.gsub!("=> 'string'", "=> 'string_1'")
    pp.gsub!("=> false", "=> true")
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end


  it 'delete remote_system' do
    pp = <<-EOS
    powerstore_remote_system { 'string':
      ensure => absent,
    }
    EOS
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end
end