# -*- coding: utf-8 -*-

=begin
This script access http://0.0.0.0:19999/ and destroy all records.
=end

require "simplecov"
begin
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
rescue Exception
end
SimpleCov.start

$:.unshift(File.join(File.dirname(File.dirname(__FILE__)), 'lib'))
require 'rubygems'
require 'active_support/cache/kyototycoon_store'
