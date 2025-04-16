# frozen_string_literal: true

require 'open-uri'

module Jekyll
  class ReferencesTag < Liquid::Tag
    safe true
    priority :normal

    def initialize(tag_name, text, tokens)
      super
      @title = text
    end

    def reference(style, ref)
      # Initialize return reference
      final_reference = ''

      # Parse article data according to style
      case style
      when 'apa', 'american psychological association'
        # Parse authors
        if ref["organization"].to_s != ''
          # If organization, use full name
          final_reference = ref["organization"].to_s + "."
        else
          # Otherwise, use APA abbreviations
          ref["authors"].map! do |author|
            author = author.split
            last_name = author.pop
            fist_names = author.map do |n|
              n[0].upcase + "."
            end
            fist_names = fist_names.join
            author = last_name + " " + fist_names

            author
          end
          final_reference = ref["authors"].join(', ') + "."
        end
        # Parse publication date
        if ref["publication"].to_s != ''
          final_reference += " (" + ref["publication"].to_s + ")."
        end
        # Parse article title
        final_reference += " " + ref["title"] + "."
        # If published in a journal
        if ref["journal"].to_s != ''
          # Parse journal
          final_reference += " " + ref["journal"]
          # Parse volume and issue
          if ref["volume"].to_s != '' and ref["issue"].to_s != ''
            final_reference += ", " + ref["volume"].to_s + "(" + ref["issue"].to_s + ")"
          elsif ref["volume"].to_s != ''
            final_reference += ", " + ref["volume"].to_s
          end
          # Parse pages
          if ref["pages"].to_s != ''
            final_reference += ", " + ref["pages"].to_s
          end
        end
        final_reference += "."
      when 'mla', 'modern language association'
        # Parse authors
        if ref["organization"].to_s != ''
          # If organization, use full name
          final_reference = ref["organization"].to_s + ". "
        elsif ref["authors"].length > 0
          # Otherwise, use authors' list
          author = ref["authors"][0].split
          last_name = author.pop
          author = author.join(" ")
          author = last_name + ", " + author

          # Append 'et al' is more than 1 author
          if ref["authors"].length > 1
            author += ", et al"
          end

          # Begin reference with author(s)
          final_reference = author + ". "
        end
        # Parse article title
        final_reference += "&ldquo;" + ref["title"] + "&rdquo;."
        # Parse journal
        if ref["journal"].to_s != ''
          final_reference += " " + ref["journal"]
        end
        # Parse volume
        if ref["volume"].to_s != ''
          final_reference += ", vol. " + ref["volume"].to_s
        end
        # Parse issue
        if ref["issue"].to_s != ''
          final_reference += ", no. " + ref["issue"].to_s
        end
        # Parse publication date
        if ref["publication"].to_s != ''
          final_reference += ", " + ref["publication"].to_s
        end
        # Parse pages
        if ref["pages"].to_s != ''
          final_reference += ", " + (ref["pages"].include?("-") ? "pp" : "p") + ". "
          final_reference += ref["pages"].to_s
        end
        final_reference += "."
      when 'chicago-annotated-bibliography'
        final_reference = []
        # Parse authors
        if ref["organization"].to_s != ''
          # If organization, use full name
          final_reference.push(ref["organization"].to_s)
        else
          # Otherwise, use Chicago listing
          if ref["authors"].length > 2
            last_author = ref["authors"].pop
            final_reference.push(ref["authors"].join(', ') + ", &amp; " + last_author)
          elsif ref["authors"].length == 2
            final_reference.push(ref["authors"].join(" &amp; "))
          else
            final_reference.push(ref["authors"][0])
          end
        end
        # Parse publication date
        if ref["publication"].to_s != ''
          final_reference.push(ref["publication"].to_s)
        end
        # Parse article title
        final_reference.push("&ldquo;" + ref["title"] + "&rdquo;")
        # Parse journal
        if ref["journal"].to_s != ''
          journal = ref["journal"]
          # Parse volume and issue
          if ref["volume"].to_s != '' and ref["issue"].to_s != ''
            journal += " " + ref["volume"].to_s + "(" + ref["issue"].to_s + ")"
          elsif ref["volume"].to_s != ''
            journal += " " + ref["volume"].to_s
          end
          # Parse pages
          if ref["pages"].to_s != ''
            journal += ": " + ref["pages"].to_s
          end

          final_reference.push(journal)
        end
        final_reference = final_reference.join(", ") + "."
      when 'ieee', 'institute of electrical and electronics engineers'
        final_reference = []
        # Parse authors
        if ref["organization"].to_s != ''
          # If organization, use full name
          final_reference.push(ref["organization"].to_s)
        else
          # Parse authors' name to IEEE abbreviation
          ref["authors"].map! do |author|
            author = author.split
            last_name = author.pop
            author.map do |name|
              name[0].upcase + "."
            end
            author = author.join(' ') + ' ' + last_name

            author
          end
          # And join them using Oxford-comma-conventions
          if ref["authors"].length > 2
            last_author = ref["authors"].pop
            final_reference.push(ref["authors"].join(', ') + ", &amp; " + last_author)
          elsif ref["authors"].length == 2
            final_reference.push(ref["authors"].join(" &amp; "))
          else
            final_reference.push(ref["authors"][0])
          end
        end
        # Parse article title
        final_reference.push("&ldquo;" + ref["title"] + "&rdquo;")
        # Parse journal
        if ref["journal"].to_s != ''
          final_reference.push(ref["journal"])
        end
        # Parse volume
        if ref["volume"].to_s != ''
          final_reference.push("vol. " + ref["volume"].to_s)
        end
        # Parse issue
        if ref["issue"].to_s != ''
          final_reference.push("no. " + ref["issue"].to_s)
        end
        # Parse pages
        if ref["pages"].to_s != ''
          final_reference.push((ref["pages"].include?("-") ? "pp" : "p") + ". " + ref["pages"].to_s)
        end
        # Parse publication date
        if ref["publication"].to_s != ''
          final_reference.push(ref["publication"].to_s)
        end
        final_reference = final_reference.join(", ") + "."
      else # Vancouver, the default
        # Parse authors
        if ref["organization"].to_s != ''
          # If organization, use full name
          final_reference = ref["organization"].to_s + "."
        else
          # Otherwise, use Vancouver abbreviations
          ref["authors"].map! do |author|
            author = author.split
            last_name = author.pop
            fist_names = author.map do |n|
              n[0].upcase
            end
            fist_names = fist_names.join('')
            author = last_name + " " + fist_names

            author
          end
          final_reference = ref["authors"].join(', ') + "."
        end
        # Parse article title
        final_reference += " " + ref["title"] + "."
        # If published in a journal
        if ref["journal"].to_s != ''
          # Parse journal
          final_reference += " " + ref["journal"] + "."
          # Parse publication date
          if ref["publication"].to_s != ''
            final_reference += " " + ref["publication"].to_s + ";"
          end
          # Parse volume and issue
          if ref["volume"].to_s != '' and ref["issue"].to_s != ''
            final_reference += ref["volume"].to_s + "(" + ref["issue"].to_s + ")"
          elsif ref["volume"].to_s != ''
            final_reference += ref["volume"].to_s
          end
          # Parse pages
          if ref["pages"].to_s != ''
            final_reference += ":" + ref["pages"].to_s
          end
        else
          # Parse publication date
          if ref["publication"].to_s != ''
            final_reference += " " + ref["publication"].to_s
          end
        end
        final_reference.gsub!(/;([:\.,])/, "\1")
        final_reference += "."
      end

      # Return parsed reference
      final_reference.gsub(/[\.,]{2}/, ".")
    end

    def parse_ref(ref, ref_style, ref_lang)
      # Initialize return reference
      final_reference = ""

      if ref_style == 'chicago' or ref_style == 'turabian' or ref_style == 'chicago/turabian'
        ref_style = 'chicago-annotated-bibliography'
      elsif ref_style == ''
        ref_style = 'vancouver'
      end

      if ref["doi"]
        # If there is a DOI set, retrieve data from it
        URI.open("https://doi.org/" + ref["doi"].to_s, 'Accept' => "text/bibliography; style=#{ref_style}; lang=#{ref_lang}") do |f|
          f.each do |line|
            final_reference = line
          end
        end
        case ref_style
        when 'apa', 'american psychological association'
          final_reference.gsub!(/(https?:\/\/doi.org\/.+)$/, '<a href="\1" targer="_blank">DOI</a>')
        when 'mla', 'modern language association'
          final_reference.gsub!(/.”/, "&rdquo;.")
          final_reference.gsub!(/Crossref, (https?:\/\/doi.org\/.+)\.$/, '<a href="\1" targer="_blank">Crossref</a>.')
        when 'chicago', 'turabian', 'chicago/turabian'
          final_reference.gsub!(/,”/, "&rdquo;,")
        when 'ieee', 'institute of electrical and electronics engineers'
          final_reference.gsub!(/^\[\d+\]/, '')
          final_reference.gsub!(/,”/, "&rdquo;,")
          final_reference.gsub!(/doi: (.+)\.$/, '<a href="https://doi.org/\1" targer="_blank">doi</a>.')
        else # Vancouver, the default
          final_reference.gsub!(/^\d+\./, '')
          final_reference.gsub!(/Available from: (.+)/, 'Available <a href="\1" targer="_blank">here</a>.')
        end
      else
        # If there isn't a DOI, mount it from metadata
        final_reference = reference(ref_style, ref)
      end

      # Return parsed reference
      final_reference
    end

    def render(context)
      # Retrieve references from page
      refs = context.registers[:page]["references"]
      # Retrieve references style
      ref_style = context.registers[:site].config["references"]["style"].downcase
      # Retrieve references language
      ref_lang = context.registers[:site].config["references"]["lang"]

      # Build output
      output = "<h2>#{@title}</h2>\n"
      output += "<ol>\n"
      refs.each do |r|
        output += "<li>#{parse_ref(r[1], ref_style, ref_lang)}</li>\n"
      end
      output += "</ol>"
      # Return output
      output
    end
  end
end

Liquid::Template.register_tag('references', Jekyll::ReferencesTag)
