# -*- coding: utf-8 -*-
require 'active_support'
require 'kyototycoon'

module ActiveSupport
  module Cache
    class KyototycoonStore < Store
      # Instantiate the store.
      #
      # Example:
      #   KyototycoonStore.new
      #     # => host: localhost, port: 1978
      #   KyototycoonStore.new "example.com"
      #     # => host: example.com, port: 1978
      #   KyototycoonStore.new "example.com:1234"
      #     # => host: example.com, port: 1234
      def initialize(*addresses)
        addresses = addresses.flatten
        options = addresses.extract_options!
        @data = build_kyoto_tycoon(addresses)
        super(options)
      end

      def increment(name, amount = 1, options = nil)
        instrument(:increment, name, :amount => amount) do
          @data.increment(name, amount)
        end
      end

      def decrement(name, amount = 1, options = nil)
        instrument(:decrement, name, :amount => amount) do
          @data.decrement(name, amount)
        end
      end

      def clear(options = nil)
        instrument(:clear, nil, nil) do
          @data.clear
        end
      end

      def delete_matched(matcher, options = nil)
        instrument(:delete_matched, matcher.inspect) do
          keys = @data.match_regex(matcher)
          @data.remove_bulk(keys)
        end
      end

      def delete_prefix(prefix, options = nil)
        instrument(:delete_prefix, prefix) do
          keys = @data.match_prefix(prefix)
          @data.remove_bulk(keys)
        end
      end

      def keys
        @data.keys
      end

      def finish
        @data.finish
      end
      alias_method :reset, :finish

      protected
      # Read an entry from the cache.
      def read_entry(key, options) # :nodoc:
        Marshal.load(@data.get(key))
      rescue => e
        logger.error("KyotoTycoonError (#{e}): #{e.message}") if logger
        nil
      end

      # Write an entry to the cache.
      def write_entry(key, entry, options) # :nodoc:
        method = options && options[:unless_exist] ? :add : :set
        expires_in = options[:expires_in].to_i
        expires_in = nil if expires_in == 0
        entry = Marshal.dump(entry)
        @data.send(method, key, entry, expires_in)
      rescue => e
        logger.error("KyotoTycoonError (#{e}): #{e.message}") if logger
        false
      end

      # Delete an entry from the cache.
      def delete_entry(key, options) # :nodoc:
        @data.remove(key)
      rescue => e
        logger.error("KyotoTycoonError (#{e}): #{e.message}") if logger
        false
      end

      private
      def build_kyoto_tycoon(addresses)
        host, port = addresses.first.split(':') if addresses.first
        host ||= KyotoTycoon::DEFAULT_HOST
        port ||= KyotoTycoon::DEFAULT_PORT
        KyotoTycoon.new(host, port.to_i)
      end
    end
  end
end
