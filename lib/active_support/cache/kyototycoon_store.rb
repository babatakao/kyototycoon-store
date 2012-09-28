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

      # increment is currently not supported (KyotoTycoon not supported increment Marshaled value)
      def increment(name, amount = 1, options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support increment")
      end

      # decrement is currently not supported (KyotoTycoon not supported decrement Marshaled value)
      def decrement(name, amount = 1, options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support decrement")
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
          options = merged_options(options)
          prefix = namespaced_key(prefix, options)
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
        if address = addresses.shift
          host, port = address.split(':')
        end
        host ||= KyotoTycoon::DEFAULT_HOST
        port ||= KyotoTycoon::DEFAULT_PORT
        kt = KyotoTycoon.new(host, port.to_i)

        # backup servers
        addresses.each do |address|
          host, port = address.split(':')
          kt.servers << [host, port.to_i]
        end
        kt
      end
    end
  end
end
