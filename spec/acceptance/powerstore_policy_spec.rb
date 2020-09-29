require 'spec_helper_acceptance'

describe 'powerstore_policy' do
  it 'get policy' do
    result = run_resource('powerstore_policy')
    expect(result).to match(%r{ensure => 'present'}).or match(%r{Completed get, returning hash \[\]})
  end

  it 'create policy' do
    pp = run_resource('powerstore_policy', 'string', false)
    pp.gsub!("string", "string_1")
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end

  
  it 'update policy' do
    pp = run_resource('powerstore_policy', 'string', false)
    pp.gsub!("=> 'string'", "=> 'string_1'")
    pp.gsub!("=> false", "=> true")
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end


  it 'delete policy' do
    pp = <<-EOS
    powerstore_policy { 'string':
      ensure => absent,
    }
    EOS
    make_site_pp(pp)
    result = run_device(allow_changes: true)
    expect(result).to match(%r{Applied catalog.*})
  end
end