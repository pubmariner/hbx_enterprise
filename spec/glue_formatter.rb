require 'rspec/core/formatters/base_formatter'
require 'rspec/core/formatters/html_printer'
require 'securerandom'

class ExampleGrouping
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
       existing = ExampleGrouping.new(k, @depth + 1)
       @groups << existing
     end
     existing.add(rest, example)
    end
  end

  def pendings?
    pending_groups? || pending_examples?
  end

  def failures?
    failed_groups? || failed_examples?
  end

  def failed_groups?
    @groups.any?(&:failures?)
  end

  def pending_groups?
    @groups.any?(&:pendings?)
  end

  def pending_examples?
    @examples.any? do |example|
      ["pending"].include?(example.execution_result[:status])
    end
  end

  def failed_examples?
    @examples.any? do |example|
      !["passed", "pending"].include?(example.execution_result[:status])
    end
  end
end

class GlueFormatter < RSpec::Core::Formatters::BaseFormatter
  include ERB::Util
  def start(example_count)
    super
    puts "Running #{example_count} tests"
    @passed_examples = []
    @example_groupings = ExampleGrouping.new("", 0)
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
    print_index_file(duration)
  end

  def print_index_file(duration)
    ifile = File.open(File.join(base_path_for_files, "index.html"), 'w')
    printer = RSpec::Core::Formatters::HtmlPrinter.new(ifile)
    printer.print_html_start
    printer.flush
    ifile.print HIDE_SHOW_JS
    ifile.print "<div id=\"nav_menu\" style=\"float: left; width: 25%;\">\n<ul>\n"
    @example_groupings.each_group do |grp|
      print_group_link(ifile, grp)
    end
    ifile.print "</ul>\n</div>"
    @example_groupings.each_group do |grp|
      ifile.print "<div class=\"example_groupings\" id=\"example_grouping_#{grp.guid}\" style=\"float: left; width: 70%; display:none;\">\n"
      div_for_group(ifile, printer, grp)
      ifile.print "</div>\n"
    end
    print_summary(printer, duration)
    ifile.close
  end

  def print_group_link(f, grp)
    example_indicators = ""
    if grp.failures?
      example_indicators << " F"
    end
    if grp.pendings?
      example_indicators << " P"
    end
    f.print "<li><a href=\"#\" onclick=\"hideExamples(); showExample('#{grp.guid}'); return false;\">#{h(grp.name)}</a>#{example_indicators}</li>\n"
  end

  def print_summary(printer, duration)
    printer.print_summary(
      false,
      duration,
      @example_count,
      @failed_examples.length,
      @pending_examples.length
    )
    printer.flush
  end

  def base_path_for_files
    File.join(File.dirname(__FILE__), "report")
  end

  def div_for_group(f, printer, grp)
    printer.flush
    print_example_group_start(f, grp)
    grp.examples.each do |example|
      case example.execution_result[:status]
      when "passed"
        printer.print_example_passed(example.description, example.execution_result[:run_time])
      when "pending"
        printer.print_example_pending(example.description, example.metadata[:execution_result][:pending_message] )
      else
        print_failed_example(printer, example.description, example)
      end
    end
    grp.each_group do |child_group|
      div_for_group(f, printer, child_group)
    end
    printer.print_example_group_end
    printer.flush
  end

  def print_failed_example(printer, description, example)
    exception = example.metadata[:execution_result][:exception]
    exception_details = if exception
                          {
                            :message => exception.message,
                            :backtrace => format_backtrace(exception.backtrace, example).join("\n")
                          }
                        else
                          false
                        end
    extra = extra_failure_content(exception)

    printer.print_example_failed(
      example.execution_result[:pending_fixed],
      description,
      example.execution_result[:run_time],
      @failed_examples.size,
      exception_details,
      (extra == "") ? false : extra,
      true
    )
  end

  def extra_failure_content(exception)
    require 'rspec/core/formatters/snippet_extractor'
    backtrace = exception.backtrace.map {|line| backtrace_line(line)}
    backtrace.compact!
    @snippet_extractor ||= RSpec::Core::Formatters::SnippetExtractor.new
    "    <pre class=\"ruby\"><code>#{@snippet_extractor.snippet(backtrace)}</code></pre>"
  end

  def print_example_group_start(output, grp)
    pending_class = (grp.pendings? ? "not_implemented" : "passed")
    css_class = (grp.failures? ? "failed" : pending_class)
    output.puts "<div id=\"div_group_#{grp.guid}\" class=\"example_group passed\">"
    output.puts "  <dl #{indentation_style(grp.depth)}>"
    output.puts "  <dt id=\"example_group_#{grp.guid}\" class=\"#{css_class}\"><pre>#{h(grp.name)}</pre></dt>"
  end

  def indentation_style( number_of_parents )
    "style=\"margin-left: #{(number_of_parents - 1) * 15}px;\""
  end

  HIDE_SHOW_JS = <<-JSCODE
  <script type="text/javascript">
  // <![CDATA[
    function hideExamples() {
  var elements = document.getElementsByClassName('example_groupings');
  for(var i = 0; i<elements.length; i++) {
     elements[i].style.display = "none";
  }
}

function showExample(eg_guid) {
  document.getElementById("example_grouping_" + eg_guid).style.display = "block";
}
// ]]>
</script>
  JSCODE
end
