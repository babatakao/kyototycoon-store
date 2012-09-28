# -*- coding: utf-8 -*-

require 'spec_helper'

describe ActiveSupport::Cache::KyototycoonStore do
  RSpec::Matchers.define :match_host_and_port do |host, port|
    match do |actual|
      actual.instance_variable_get(:@data).servers == [[host, port]]
    end
  end
  RSpec::Matchers.define :match_hosts_and_ports do |*servers|
    match do |actual|
      actual.instance_variable_get(:@data).servers == servers
    end
  end
  RSpec::Matchers.define :match_options do |options|
    match do |actual|
      actual.instance_variable_get(:@options) == options
    end
  end

  it "Default = 0.0.0.0:1978" do
    store = ActiveSupport::Cache::KyototycoonStore.new
    store.should match_host_and_port('0.0.0.0', 1978)
  end
  it "Configure options" do
    store = ActiveSupport::Cache::KyototycoonStore.new(:expires_in => 10)
    store.should match_host_and_port('0.0.0.0', 1978)
  end
  it "Configure IP address" do
    store = ActiveSupport::Cache::KyototycoonStore.new('10.0.0.1')
    store.should match_host_and_port('10.0.0.1', 1978)
  end
  it "Configure IP address with options" do
    store = ActiveSupport::Cache::KyototycoonStore.new('10.0.0.1', :expires_in => 10)
    store.should match_host_and_port('10.0.0.1', 1978)
  end
  it "Configure hostname" do
    store = ActiveSupport::Cache::KyototycoonStore.new('example.com')
    store.should match_host_and_port('example.com', 1978)
  end
  it "Configure hostname with options" do
    store = ActiveSupport::Cache::KyototycoonStore.new('example.com', :expires_in => 10)
    store.should match_host_and_port('example.com', 1978)
  end
  it "Configure IP address and port" do
    store = ActiveSupport::Cache::KyototycoonStore.new('192.168.0.1:19999')
    store.should match_host_and_port('192.168.0.1', 19999)
  end
  it "Configure IP address and port with options" do
    store = ActiveSupport::Cache::KyototycoonStore.new('192.168.0.1:19999', :expires_in => 10)
    store.should match_host_and_port('192.168.0.1', 19999)
  end
  it "Configure hostname and port" do
    store = ActiveSupport::Cache::KyototycoonStore.new('example.com:19999')
    store.should match_host_and_port('example.com', 19999)
  end
  it "Configure hostname and port with options" do
    store = ActiveSupport::Cache::KyototycoonStore.new('example.com:19999', :expires_int => 10)
    store.should match_host_and_port('example.com', 19999)
  end
  it "Configure backup servers" do
    store = ActiveSupport::Cache::KyototycoonStore.new('10.0.0.1:1234', 'example.com:19999')
    store.should match_hosts_and_ports(['10.0.0.1', 1234], ['example.com', 19999])
  end
  it "Configure backup servers with options" do
    store = ActiveSupport::Cache::KyototycoonStore.new('10.0.0.1:1234', 'example.com:19999', :expires_in => 10)
    store.should match_hosts_and_ports(['10.0.0.1', 1234], ['example.com', 19999])
  end
  it "Check options" do
    store = ActiveSupport::Cache::KyototycoonStore.new(:expires_in => 10)
    store.should match_options(:expires_in => 10)
  end
end