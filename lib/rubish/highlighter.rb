# frozen_string_literal: true

require 'strscan'
require 'set'

module Rubish
  # Lightweight syntax highlighter for the input buffer. Driven by a
  # StringScanner rather than the real Lexer because Lexer tokens carry
  # no source positions, and re-running the full lexer on every keystroke
  # is more expensive than a focused regex pass. Aim is "good enough"
  # coloring while typing -- exact parser fidelity is not required.
  module Highlighter
    RESET    = "\e[0m"
    COMMENT  = "\e[90m"
    STRING   = "\e[33m"
    VAR      = "\e[35m"
    KEYWORD  = "\e[34m"
    BUILTIN  = "\e[36m"
    COMMAND  = "\e[92m"  # external executable on PATH
    FLAG     = "\e[96m"  # -x / --long
    NUMBER   = "\e[32m"
    OPERATOR = "\e[31m"

    # Keyword set mirrors Lexer::KEYWORDS values. Duplicated here to keep
    # the highlighter independent of lexer internals.
    KEYWORDS = Set.new(%w[
      if unless then else elif elsif fi while until for select function
      def case when esac coproc time lazy_load do done in end return
    ])

    # Max length above which we skip highlighting to keep keystrokes snappy.
    MAX_LEN = 4096

    module_function

    def colorize(text)
      return text if text.nil? || text.empty?
      return text if text.length > MAX_LEN

      builtins = builtin_set
      out = String.new(capacity: text.bytesize + 32)
      ss = StringScanner.new(text)
      # At a position where the next word names a command (builtin or exec).
      # True at start and after operators / certain keywords.
      expect_command = true

      until ss.eos?
        if (m = ss.scan(/[ \t]+/))
          out << m
        elsif (m = ss.scan(/#[^\n]*/))
          out << COMMENT << m << RESET
        elsif (m = ss.scan(/"(?:\\.|[^"\\])*"?/))
          out << STRING << m << RESET
          expect_command = false
        elsif (m = ss.scan(/'[^']*'?/))
          out << STRING << m << RESET
          expect_command = false
        elsif (m = ss.scan(/\$\{[^}]*\}?|\$[A-Za-z_][A-Za-z0-9_]*|\$[0-9*@#?!$-]/))
          out << VAR << m << RESET
          expect_command = false
        elsif (m = ss.scan(/--[A-Za-z][A-Za-z0-9_-]*|-[A-Za-z0-9]+/))
          out << FLAG << m << RESET
        elsif (m = ss.scan(/\b\d+(?:\.\d+)?\b/))
          out << NUMBER << m << RESET
          expect_command = false
        elsif (m = ss.scan(/&&|\|\||\|&|;;&|;;|;&|>>|<<<|<<-|<<|>\||2>|>&|<&|[|;&(){}<>\n]/))
          out << OPERATOR << m << RESET
          expect_command = true
        elsif (m = ss.scan(%r{(?:\./|/)[\w./-]+}))
          # Path-style command at command position (e.g. /usr/bin/ls, ./script).
          if expect_command && executable_path?(m)
            out << COMMAND << m << RESET
          else
            out << m
          end
          expect_command = false
        elsif (m = ss.scan(/[A-Za-z_][A-Za-z0-9_]*/))
          if KEYWORDS.include?(m)
            out << KEYWORD << m << RESET
            expect_command = true
          elsif expect_command && builtins.include?(m)
            out << BUILTIN << m << RESET
            expect_command = false
          elsif expect_command && command_on_path?(m)
            out << COMMAND << m << RESET
            expect_command = false
          else
            out << m
            expect_command = false
          end
        else
          # Any other byte (unicode, punctuation we don't classify) -- pass through.
          out << ss.getch
        end
      end

      out
    end

    # Builtins list lives on Runtime::Builtins::COMMANDS, loaded after
    # this module. Resolve lazily and memoize per-process. Returns a Set
    # for O(1) lookup.
    def builtin_set
      @builtin_set ||= begin
        list = nil
        %w[Rubish::Builtins::COMMANDS Rubish::Runtime::Builtins::COMMANDS].each do |path|
          obj = path.split('::').inject(Object) { |o, n| o.const_defined?(n) ? o.const_get(n) : (break nil) }
          if obj.is_a?(Array)
            list = obj
            break
          end
        end
        Set.new(list || [])
      end
    end

    # Auto-refresh interval for the PATH index. Bounds staleness from
    # commands installed mid-session (e.g. `brew install`) without
    # rescanning every keystroke.
    REFRESH_INTERVAL = 30.0
    # Minimum age before a miss triggers an opportunistic refresh.
    # Keeps the worst-case lag from a new-install to "type it once,
    # wait a couple seconds, type it again."
    REFRESH_ON_MISS_AFTER = 2.0

    # Returns the cached Set of executable basenames from PATH. Built
    # lazily, refreshed on TTL. Lookups are O(1) Set#include?, so the
    # per-keystroke cost is bounded -- no fs syscalls in the hot path.
    def path_index
      now = Time.now.to_f
      if @path_index.nil? || (now - (@path_index_at || 0)) >= REFRESH_INTERVAL
        rebuild_path_index(now)
      end
      @path_index
    end

    def rebuild_path_index(now = Time.now.to_f)
      set = Set.new
      ENV['PATH'].to_s.split(File::PATH_SEPARATOR).each do |dir|
        next if dir.empty?
        begin
          Dir.children(dir).each { |name| set << name }
        rescue SystemCallError
          # Unreadable / nonexistent PATH dirs are common; ignore.
        end
      end
      @path_index = set
      @path_index_at = now
    end

    def command_on_path?(name)
      return true if path_index.include?(name)
      # Miss may mean "really not a command" or "installed since last scan".
      # Refresh on miss, but throttled so fast typing doesn't trigger a
      # rebuild per keystroke.
      now = Time.now.to_f
      if (now - @path_index_at) >= REFRESH_ON_MISS_AFTER
        rebuild_path_index(now)
        return @path_index.include?(name)
      end
      false
    end

    def executable_path?(path)
      @path_cache ||= {}
      return @path_cache[path] if @path_cache.key?(path)
      @path_cache[path] = File.file?(path) && File.executable?(path)
    end
  end
end
