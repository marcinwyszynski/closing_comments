require 'forwardable'
require 'parser/ruby24'

module ClosingComments
  class Source
    extend Forwardable

    attr_reader :path, :content
    def_delegators :visitor, :entities

    def self.from(path:)
      new(path: path, content: File.read(path))
    end

    def initialize(path:, content:)
      @path = path
      @content = content
    end

    def problematic?
      problems.count.positive?
    end

    def problems
      @problems ||=
        entities
        .reject(&:single_line?)
        .reject(&method(:commented?))
        .map { |ent| Problem.new(ent, line(number: ent.last_line)) }
    end

    def fix
      lines.map.with_index(1) { |default, no| fixes[no] || default }.join("\n")
    end

    private

    def fixes
      @fixes ||=
        problems
        .map { |problem| [problem.line, problem.fix] }
        .to_h
    end

    def line(number:)
      lines[number - 1]
    end

    def lines
      @lines ||= content.split("\n")
    end

    # This method reeks of :reek:FeatureEnvy (entity).
    def commented?(entity)
      line(number: entity.last_line).end_with?(entity.ending)
    end

    def visitor
      @visitor ||= visitor_class.new(content)
    end

    def visitor_class
      path.end_with?('_spec.rb') ? Visitor::Spec : Visitor
    end

    class Problem
      def initialize(entity, line)
        @entity = entity
        @line = line
      end

      def line
        @entity.last_line
      end

      def column
        @line.index('end')
      end

      def fix
        @line[0...column] + @entity.ending
      end

      def message
        "missing #{@entity.entity} closing comment"
      end

      def to_h
        {
          line: line,
          column: column,
          message: message,
        }
      end
    end # class Problem

    class Visitor
      attr_reader :entities

      def initialize(content)
        @entities = []
        recursively_visit(Parser::Ruby24.parse(content))
        entities.freeze
      end

      private

      def recursively_visit(node)
        return unless node.is_a?(Parser::AST::Node)
        visit_current(node)
        node.children.each(&method(:recursively_visit))
      end

      def visit_current(node)
        case node.type
        when :class then entities << Commentable::Class.new(node)
        when :module then entities << Commentable::Module.new(node)
        end
      end

      class Spec < Visitor
        private

        def visit_current(node)
          return super unless node.type == :block
          block = Commentable::Block.new(node)
          entities << block if block.commentable?
        end
      end # class Spec
    end # class Visitor
    private_constant :Visitor
  end # class Source
end # module ClosingComments
