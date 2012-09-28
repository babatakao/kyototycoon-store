# -*- coding: utf-8 -*-

require 'spec_helper'

describe ActiveSupport::Cache::KyototycoonStore do
  RSpec::Matchers.define :be_kt_error do
    match do |actual|
      actual.is_a?(Hash) && actual.key?('ERROR')
    end
  end
  RSpec::Matchers.define :be_kt_success do
    match do |actual|
      actual == { }
    end
  end
  RSpec::Matchers.define :changed_kt_number_of_values do |expected|
    match do |actual|
      actual == { 'num' => expected.to_s }
    end
  end
  RSpec::Matchers.define :be_eql_array do |expected|
    match do |actual|
      (expected & actual) == expected
    end
  end

  before(:all) do
    @store = ActiveSupport::Cache::KyototycoonStore.new('0.0.0.0:19999')
    @store.clear
  end
  after(:each) do
    @store.clear
  end

  describe "Store should be empty when initialized" do
    it { @store.keys.should be_empty }
  end
  describe "read" do
    it "read unstored key should be nil" do
      @store.read('hoge').should be_nil
      @store.read(:hoge).should be_nil
    end
  end
  describe "write" do
    it "write should be success" do
      @store.write('hoge', 'piyo').should be_kt_success
    end
    it "write nil data should be success" do
      @store.write('hoge', nil).should be_kt_success
    end
    it "write nil key should be fail" do
      @store.write(nil, nil).should be_false
    end
    it "write two times should be success" do
      @store.write('hoge', 'piyo').should be_kt_success
      @store.write('hoge', 'piyo').should be_kt_success
    end
    it "write two times with :unless_exist should raise error" do
      @store.write('hoge', 'piyo', :unless_exist => true).should be_kt_success
      @store.write('hoge', 'fuga', :unless_exist => true).should be_kt_error
    end
    it "write two times with :unless_exist should raise error (symbol and string)" do
      @store.write('hoge', 'piyo', :unless_exist => true).should be_kt_success
      @store.write(:hoge, 'fuga', :unless_exist => true).should be_kt_error
    end
  end
  describe "read,write" do
    before do
      @values = {
        :key_alpha => 'abcdefg',
        :key_number => 123456,
        :key_array => [1, 2, '3'],
        :key_hash => { :hoge => 'piyo', :foo => 'bar' },
        :key_nil => nil,
        123 => 'number key',
      }
      @values.each do |k, v|
        @store.write(k, v)
      end
    end
    it "should stored keys" do
      @store.keys.should be_eql_array(@values.keys.map(&:to_s))
    end
    it "should be able to read each value" do
      @values.each do |k, v|
        @store.read(k).should == v
      end
    end
    it "should be able to read each value with stringify key" do
      @values.each do |k, v|
        @store.read(k.to_s).should == v
      end
    end
    it "can overwrite value" do
      @store.write(:key_alpha, 'newvalue')
      @store.read(:key_alpha).should == 'newvalue'
    end
    it "key is case sensitive" do
      @store.read(:key_alpha).should_not eq @store.read(:Key_alpha)
    end
  end
  describe "delete" do
    before do
      @keys = [:a, :b, :c]
      @keys.each_with_index do |k, i|
        @store.write k, i
      end
    end
    it "should be stored" do
      @keys.each do |k|
        @store.read(k).should_not be_nil
      end
    end
    it "delete stored value should change 1 value" do
      @store.delete(:a).should changed_kt_number_of_values(1)
    end
    it "delete unstored value should change 0 value" do
      @store.delete(:z).should changed_kt_number_of_values(0)
    end
    it "should be nil after deleted" do
      @store.delete(:a)
      @store.read(:a).should be_nil
    end
    it "delete with error should returns false" do
      @store.instance_variable_get(:@data).stub(:remove).and_raise('error')
      @store.delete(:a).should be_false
    end
  end
  describe "delete_prefix, delete_matched" do
    before do
      @keys = ['http://example.com', 'http://10.0.0.1', 'abcdefg']
      @keys.each_with_index do |k, i|
        @store.write k, i
      end
    end
    it "should be stored" do
      @store.keys.length == @keys.length
    end
    it "delete_matched with empty regexp removes all keys" do
      @store.delete_matched(//).should changed_kt_number_of_values(@keys.length)
      @store.keys.should be_empty
    end
    it "delete_matched with empty string removes all keys" do
      @store.delete_matched('').should changed_kt_number_of_values(@keys.length)
      @store.keys.should be_empty
    end
    it "delete_matched removes regexp matched keys(1)" do
      @store.delete_matched(/10/).should changed_kt_number_of_values(1)
      @store.read('http://10.0.0.1').should be_nil
    end
    it "delete_matched removes regexp matched keys(2)" do
      @store.delete_matched(/ttp/).should changed_kt_number_of_values(2)
      @store.read('http://10.0.0.1').should be_nil
    end
    it "delete_matched removes regexp matched keys(3)" do
      @store.delete_matched(/hogehoge/).should changed_kt_number_of_values(0)
    end
    it "delete_matched removes regexp matched keys(4)" do
      @store.delete_matched(/HTTP/).should changed_kt_number_of_values(0)
      @store.read('http://10.0.0.1').should_not be_nil
    end
    it "delete_matched removes regexp matched keys(5)" do
      @store.delete_matched(/abc$/).should changed_kt_number_of_values(0)
      @store.read('abcdefg').should_not be_nil
    end
    it "delete_prefix with empty string removes all keys" do
      @store.delete_prefix('').should changed_kt_number_of_values(@keys.length)
      @store.keys.should be_empty
    end
    it "delete_prefix removes matched keys(1)" do
      @store.delete_prefix('http').should changed_kt_number_of_values(2)
      @store.read('http://example.com').should be_nil
    end
    it "delete_prefix removes matched keys(2)" do
      @store.delete_prefix('bcdefg').should changed_kt_number_of_values(0)
      @store.read('abcdefg').should_not be_nil
    end
    it "delete_prefix removes matched keys(3)" do
      @store.delete_prefix('HTTP').should changed_kt_number_of_values(0)
      @store.read('http://example.com').should_not be_nil
    end
  end
  describe "increment,decrement" do
    it "increment is currently not implemented" do
      proc { @store.increment(:a) }.should raise_error(NotImplementedError)
    end
    it "decrement is currently not implemented" do
      proc { @store.decrement(:a) }.should raise_error(NotImplementedError)
    end
  end
  describe "clear" do
    before do
      @store.write(:hoge, 'piyo')
    end
    it "should be stored" do
      @store.keys.length.should == 1
    end
    it "should be empty after clear" do
      @store.clear
      @store.keys.should be_empty
    end
  end
  describe "finish" do
    before do
      @store.write(:hoge, 'piyo')
    end
    it "should be able to connect after finished" do
      @store.finish
      @store.read(:hoge).should == 'piyo'
    end
    it "should be able to connect after reset" do
      @store.reset
      @store.read(:hoge).should == 'piyo'
    end
  end
  describe "large key (1MB)" do
    before do
      @key = "long long " * 100 * 1000
      @store.write(@key, "foo")
    end
    it "key length is 1MB" do
      @key.length.should == 1000 * 1000
    end
    it "should be stored" do
      @store.keys.first.should == @key
    end
  end
  describe "large value (10MB)" do
    before do
      @store.write('10MB', 'a' * 1000 * 1000 * 10)
    end
    it "should be stored" do
      @store.read('10MB').length.should == 1000 * 1000 * 10
      @store.read('10MB').should == 'a' * 1000 * 1000 * 10
    end
  end
  describe "expires_in" do
    before do
      @store.write('foo', 'bar', :expires_in => 1)
    end
    it "should be stored" do
      @store.read('foo').should == 'bar'
    end
    it "should be removed after 1 seconds" do
      sleep(1)
      @store.read('foo').should be_nil
    end
  end
end

