# -*- coding: utf-8 -*-

require 'spec_helper'

describe ActiveSupport::Cache::KyototycoonStore do
  before(:all) do
    @store = ActiveSupport::Cache::KyototycoonStore.new('0.0.0.0:19999', :namespace => 'KT')
    @store.clear
  end
  after(:each) do
    @store.clear
  end

  describe "Store should be empty when initialized" do
    it { @store.keys.should be_empty }
  end
  describe "namespaced key" do
    before do
      @store.write('foo', 'bar')
    end
    it "should added prefix" do
      @store.keys.first.should == 'KT:foo'
    end
    it "should be able to read without prefix" do
      @store.read('foo').should == 'bar'
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
    it "should be nil after deleted" do
      @store.delete(:a)
      @store.read(:a).should be_nil
    end
  end
  describe "delete_prefix, delete_matched" do
    before do
      @keys = ['http://example.com', 'http://10.0.0.1', 'abcdefg']
      @keys.each_with_index do |k, i|
        @store.write k, i
      end
    end
    it "delete_matched with empty regexp removes all keys" do
      @store.delete_matched(//)
      @store.keys.should be_empty
    end
    it "delete_matched with empty string removes all keys" do
      @store.delete_matched('')
      @store.keys.should be_empty
    end
    it "delete_matched removes regexp matched keys(1)" do
      @store.delete_matched(/http/)
      @store.read('http://10.0.0.1').should be_nil
    end
    it "delete_matched removes regexp matched keys(2)" do
      @store.delete_matched(/^http/)
      @store.read('http://10.0.0.1').should_not be_nil
    end
    it "delete_prefix with empty string removes all keys" do
      @store.delete_prefix('')
      @store.keys.should be_empty
    end
    it "delete_prefix removes matched keys(1)" do
      @store.delete_prefix('http')
      @store.read('http://example.com').should be_nil
    end
  end
end
