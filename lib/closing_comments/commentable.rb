require 'forwardable'
require 'singleton'

module ClosingComments
  class Commentable
    extend Forwardable

    def_delegators :@node, :children, :loc
    def_delegators :loc, :first_line, :last_line

    def initialize(node)
      @node = node
    end

    def name
      @name ||= name!(children.first)
    end

    def single_line?
      first_line == last_line
    end

    def ending
      "end # #{entity} #{name}"
    end

    private

    # This method reeks of :reek:FeatureEnvy and :reek:TooManyStatements.
    def name!(node)
      return node unless node.is_a?(Parser::AST::Node)
      type = node.type
      return '' if type == :cbase
      first, second = node.children
      if type == :str
        loc = node.loc
        # Preserve quote formatting, some folks may prefer double quotes.
        return "#{loc.begin.source}#{first}#{loc.end.source}"
      end
      first ? [name!(first), second].join('::') : second
    end

    class Class < Commentable
      def entity
        'class'
      end
    end # class Class

    class Module < Commentable
      def entity
        'module'
      end
    end # class Module

    class Block < Commentable
      RSPEC = %i[context describe shared_context shared_examples].freeze
      private_constant :RSPEC

      def commentable?
        dispatch.type == :send && rspec?
      end

      def name
        name!(dispatch.children.last)
      end

      def entity
        return message if implicit_receiver?
        [name!(receiver), message].join('.')
      end

      private

      def rspec?
        return false unless implicit_receiver? || name!(receiver) == :RSpec
        RSPEC.include?(message)
      end

      def dispatch
        children.first
      end

      def receiver
        dispatch.children.first
      end

      # This method reeks of :reek:NilCheck.
      def implicit_receiver?
        receiver.nil?
      end

      def message
        dispatch.children[1]
      end
    end # class Block
  end # class Commentable
end # module ClosingComments
