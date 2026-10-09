# frozen_string_literal: true

module PeppolCodeLists
  # One Peppol code list. Matching is exact and case-sensitive, like the Peppol schematron rules.
  class CodeList
    attr_reader :key, :identifier, :title, :version, :source, :codes

    def self.from_hash(key, data)
      codes = data.fetch("codes").map do |code|
        Code.new(id: code.fetch("id"), name: code.fetch("name"), description: code["description"])
      end

      new(key:, identifier: data.fetch("identifier"), title: data.fetch("title"),
          version: data["version"], source: data.fetch("source"), codes:)
    end

    def initialize(key:, identifier:, title:, version:, source:, codes:)
      @key = key
      @identifier = identifier
      @title = title
      @version = version
      @source = source
      @codes = codes.freeze
      @index = codes.to_h { |code| [code.id, code] }.freeze
      freeze
    end

    def valid?(id)
      @index.key?(id)
    end
    alias include? valid?

    def find(id)
      @index[id]
    end
    alias [] find

    def fetch(id)
      @index.fetch(id) { raise UnknownCode, "#{id.inspect} is not a code in #{identifier}" }
    end

    def ids
      @index.keys
    end

    def size
      @codes.size
    end

    def inspect
      "#<#{self.class.name} #{key} (#{identifier}#{" #{version}" if version}, #{size} codes)>"
    end
  end
end
