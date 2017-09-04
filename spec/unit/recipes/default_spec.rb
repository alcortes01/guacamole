#
# Cookbook:: guacamole
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'guacamole::default' do
  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs required dependencies'
    it 'installs optional dependencies'
    it 'downloads the server source code'
    it 'builds and installs the server code'
    it 'downloads the client source code'
    it 'packages the client as a war file'
    it 'deploys the client war file'
    it 'starts guacamole client'
    it 'starts guacamole server'
  end
end
