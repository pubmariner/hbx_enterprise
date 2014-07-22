module DescriptionListHelper

  def display_aliased_fields(m,i,options = {})

    (m.aliased_fields.keys - options[:remove] + options[:add]).reduce('') { |c, x|
      options[:replace].has_key?(x) ? c << content_tag(:dt, m.human_attribute_name(options[:replace][x])) : c << content_tag(:dt, m.human_attribute_name(x))
      c << content_tag(:dd, i.method(x).call)
    }.html_safe
  end

end

