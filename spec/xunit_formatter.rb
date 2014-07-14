require 'rspec/core/formatters/base_formatter'
require 'rspec/core/formatters/html_printer'
require 'rspec/core/formatters/helpers'
require 'securerandom'

class SuiteGrouping
  include ERB::Util
  include RSpec::Core::BacktraceFormatter
  attr_reader :examples, :groups, :name, :depth, :guid

  def each_group
    @groups.sort_by(&:name).each do |g|
      yield g
    end
  end

  def initialize(n, d)
    @guid = SecureRandom.hex 
    @depth = d
    @name = n
    @examples = []
    @groups = []
  end

  def add(key, example)
    if key.empty?
      @examples << example
    else
     rest = key.dup
     k = rest.shift
     existing = @groups.detect { |g| g.name == k }
     unless existing
       existing = self.class.new(k, @depth + 1)
       @groups << existing
     end
     existing.add(rest, example)
    end
  end

  def duration
    g_time = @groups.inject(0.0) do |acc, grp|
      acc + grp.duration
    end
    e_time = @examples.inject(0.0) do |acc, ex|
      acc + ex.execution_result[:run_time]
    end
    g_time + e_time
  end

  def print_results(output)
    run_time = sprintf("%.5f", self.duration)
    if self.depth > 0
      output.print("  " * depth)
      output.puts("<testsuite name=\"#{h(name)}\" time=\"#{run_time}\">")
    end
    each_group do |grp|
      grp.print_results(output)
    end
    @examples.each do |ex|
      print_example(output, ex)
    end
    if self.depth > 0
      output.print("  " * depth)
      output.puts("</testsuite>")
    end
  end

  def print_example(output, example)
    run_time = example.execution_result[:run_time]
    duration = sprintf("%.5f", run_time)
    output.print("  " * (depth + 1))
    case example.execution_result[:status]
    when "passed"
      output.puts("<testcase name=\"#{h(example.description)}\" time=\"#{duration}\"/>")
    when "pending"
      output.puts("<testcase name=\"#{h(example.description)}\" time=\"#{duration}\">")
      output.print("  " * (depth + 2))
      output.puts("<skipped/>")
      output.print("  " * (depth + 1))
      output.puts("</testcase>")
    else
      output.puts("<testcase name=\"#{h(example.description)}\" time=\"#{duration}\">")
      print_example_failure_messages(output, example)
      output.puts("</testcase>")
    end
  end

  def print_example_failure_messages(output, example)
    exception = example.metadata[:execution_result][:exception]
    exception_details = if exception
                          {
                            :message => exception.message,
                            :backtrace => format_backtrace(exception.backtrace, example.metadata).join("\n")
                          }
                        else
                          false
                        end
    extra = extra_failure_content(exception)
    output.print("  " * (depth + 2))
    output.puts("<failure message=\"#{h(exception.message)}\">")
    output.puts(extra)
    output.print("  " * (depth + 2))
    output.puts("</failure>")
  end

  def extra_failure_content(exception)
    require 'rspec/core/formatters/snippet_extractor'
    backtrace = exception.backtrace.map {|line| backtrace_line(line)}
    backtrace.compact!
    @snippet_extractor ||= RSpec::Core::Formatters::SnippetExtractor.new
    raw_code, line = @snippet_extractor.snippet_for(backtrace[0])
    "#{h(raw_code)}"
  end
end

class XunitFormatter < RSpec::Core::Formatters::BaseFormatter
  include ERB::Util
  def start(example_count)
    super
    puts "Running #{example_count} tests"
    @passed_examples = []
    @example_groupings = SuiteGrouping.new("", 0)
  end

  def example_passed(example)
    @passed_examples << example
  end

  def flatten_example(example)
    md = example.metadata
    description_stack = []
    current_eg = md
    while (current_eg.has_key?(:example_group))
      current_eg[:example_group][:description_args].reverse.each do |arg|
        description_stack << arg
      end
      current_eg = current_eg[:example_group]
    end
    description_stack.reverse.flatten.map(&:to_s)
  end

  def add_to_examples_hash(ex)
    full_key = flatten_example(ex)
    @example_groupings.add(full_key, ex)
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @passed_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    @pending_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    @failed_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    print_test_file(duration, example_count, failure_count, pending_count)
  end

  def print_test_file(duration, example_count, failure_count, pending_count)
    with_open_file(duration, example_count, failure_count, pending_count) do |output|
      @example_groupings.each_group do |example_group|
        example_group.print_results(output)
      end
    end
  end

  def with_open_file(duration, example_count, failure_count, pending_count)
    ifile = File.open(File.join(base_path_for_files, "xunit.xml"), 'w')
    ifile.puts("<testsuites tests=\"#{example_count}\" failures=\"#{failure_count}\" errors=\"0\" ignored=\"#{pending_count}\" time=\"#{duration}\">")
    yield ifile
    ifile.puts("</testsuites>")
    ifile.flush
    ifile.close
  end

  def base_path_for_files
    File.join(File.dirname(__FILE__), "report")
  end

end
