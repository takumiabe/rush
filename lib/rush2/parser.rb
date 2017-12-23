require 'shellwords'

module Rush2
=begin
S := EXPR
EXPR := TERM ("||" TERM)*
TERM := FACTOR ("&&" FACTOR)*
FACTOR := PIPES ("|" PIPES)*
PIPES := "(" EXPR ")"
PIPES := COMMAND

parse "A || B | C && D > E"
->
  or
    and
      pipes
        A
    and
      pipes
        B
        C
      pipes
        D
        >
        E
=end
  class Tokens
    def initialize(code)
      @tokens = Shellwords.split(code)
      @index = 0
    end

    def next_token
      @tokens[@index]
    end

    def consume
      @index += 1
    end

    def scan?(target)
      return nil if next_token != target

      consume
      true
    end

    def end?
      @tokens.size == @index
    end
  end

  class Parser
    def parse(code)
      @tokens = Tokens.new(code)

      parse_expr
    end

    private

    def parse_expr
      exprs = []
      begin
        exprs << parse_term
      end while !@tokens.end? && @tokens.scan?("||")
      Node.new(:or, exprs)
    end

    def parse_term
      terms = []
      begin
        terms << parse_factor
      end while !@tokens.end? && @tokens.scan?("&&")
      Node.new(:and, terms)
    end

    def parse_factor
      pipes = []
      begin
        pipes << parse_command
      end while @tokens.scan?("|")
      Node.new(:pipes, pipes)
    end

    def parse_command
      if @tokens.scan? "("
        ret = parse_expr
        unless @tokens.scan? ")"
          raise "Unexpected Token #{@tokens.next_token} (expect: ) )"
        end
        return Node.new(:subshell, [ret])
      end

      command = []
      while a = parse_word
        command << a
      end
      Node.new(:command, command)
    end

    def parse_word
      a = @tokens.next_token

      return nil if a == "||"
      return nil if a == "&&"
      return nil if a == "|"
      return nil if a == ")"

      @tokens.consume
      return a
    end
  end

  Node = Struct.new(:type, :children)
end
