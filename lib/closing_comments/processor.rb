module ClosingComments
  class Processor
    def initialize
      @reportables = {}
    end

    # TODO(marcinw): catch parsing errors;
    def process(path:)
      source = Source.from(path: path)
      handle(source)
      @reportables[path] = source if source.problematic?
    end

    private

    attr_reader :reportables

    class Reporter < Processor
      def handle(source)
        print source.problematic? ? 'F' : '.'
      end

      def report
        puts("\n\n")
        return puts 'All good!' if reportables.empty?
        puts "Problems #{action} in #{reportables.count} files:\n\n"
        reportables.each(&method(:report_file))
      end

      private

      def action
        'found'
      end

      def report_file(path, source)
        puts "#{path}:"
        source.problems.sort_by(&:line).each do |problem|
          puts "  #{problem.line}:#{problem.column} #{problem.message}"
        end
        puts('')
      end
    end # class Reporter

    class Fixer < Reporter
      # This method reeks of :reek:FeatureEnvy.
      def handle(source)
        return super unless source.problematic?
        File.write(source.path, source.fix)
        print 'A'
      end

      private

      def action
        'fixed'
      end
    end # class Fixer

    class JSON < Processor
      def handle(_); end # Don't stare, I'm just implementing an API, ok?
    end # class JSON
  end # class Processor
end # module ClosingComments
