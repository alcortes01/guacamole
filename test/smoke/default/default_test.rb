# # encoding: utf-8

# Inspec test for recipe guacamole::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe service('tomcat8') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe service('guacd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
