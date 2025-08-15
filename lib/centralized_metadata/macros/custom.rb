# frozen_string_literal: true

# A set of custom traject macros (extractors and normalizers) used by the
module CentralizedMetadata::Macros::Custom
  def extract_original_key
    lambda do |rec, acc|
      field = rec["384"]

      if field&.indicator1 == "0" || field&.indicator1 == " "
        field.subfields.each { |sf| acc << sf.value if sf.code == "a" }
      end
    end
  end

  def extract_work_time_creation
    lambda do |rec, acc|
      field = rec["388"]

      if field&.indicator1 == "1" || field&.indicator1 == " "
        field.subfields.each { |sf| acc << sf.value if sf.code == "a" }
      end
    end
  end

  def extract_use_subject
    lambda do |rec, acc|
      acc << "YES" if rec["008"].value[15] == "a"
    end
  end

  def extract_undiff_name
    lambda do |rec, acc|
      acc << "YES" if rec["008"].value[32] == "b"
    end
  end

  def get_field_value(rec, field_name, label_name)
    rec[field_name][label_name] if rec[field_name]
  end

  def set_type
    lambda do |rec, acc|
      case
      when rec["100"]&.indicator1 != "3" &&
        rec["100"]&.subfields&.none? { |sf| sf.code == "t" }
        
        acc << "personal name"

      when rec["100"]&.indicator1 == "3" &&
        rec["100"]&.subfields&.none? { |sf| sf.code == "t" }
      
        acc << "family name"

      when  rec["110"]&.subfields&.none? { |sf| sf.code == "t" }
        acc << "corporate name"

      when  rec["111"]&.subfields&.none? { |sf| sf.code == "t" }
        acc << "conference name"

      when  rec["100"]&.subfields&.any? { |sf| sf.code == "t" } ||
        rec["110"]&.subfields&.any? { |sf| sf.code == "t" }  ||
        rec["111"]&.subfields&.any? { |sf| sf.code == "t" }
        
        acc << "name-title work"
      
      when rec["130"]
        acc << "uniform title work"

      when rec["147"]
        acc << "named event"
      
      when rec["148"]
        acc << "chronological term"

      when rec["150"] && get_field_value(rec, "040", "f") == "lcdgt"
        acc << "demographic group term"

      when rec["150"] && get_field_value(rec, "040", "f") != "lcdgt"
        acc << "topical subject"

      when rec["151"]
        acc << "geographic subject"
      
      when rec["155"]
        acc << "genre"

      when rec["162"]
        acc << "medium of performance term"
      end
    end
  end

  def extract_see_also
    lambda do |rec, acc|
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av:562a").collect_matching_lines(rec) do |field, spec, extractor|
        see_also_datafields = rec.fields.select { |f| f if extractor.interesting_tag?(f.tag) }
        selected_datafields = field if see_also_datafields.include?(field)
      
        if selected_datafields&.subfields&.none? { |sf| sf.code == "w" } ||
          selected_datafields&.any? { |f| f.code == "w" && !f.value&.start_with?("g") } ||
          selected_datafields&.any? { |f| f.code == "w" && !f.value&.start_with?("h") }
          
          acc << extractor.collect_subfields(selected_datafields, spec).first
        end
      end  
    end
  end  
  
  def extract_narrower_term
    lambda do |rec, acc|
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av:562a").collect_matching_lines(rec) do |field, spec, extractor|
        narrower_term_datafields = rec.fields.select { |f| f if extractor.interesting_tag?(f.tag) }
        selected_datafields = field if narrower_term_datafields.include?(field)
        
        if selected_datafields&.any? { |f| f.code == "w" && f.value&.start_with?("h") }

          acc << extractor.collect_subfields(selected_datafields, spec).first
        end
      end  
    end
  end

  def extract_broader_term
    lambda do |rec, acc|
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av:562a").collect_matching_lines(rec) do |field, spec, extractor|
        broader_term_datafields = rec.fields.select { |f| f if extractor.interesting_tag?(f.tag) }
        selected_datafields = field if broader_term_datafields.include?(field)
        
        if selected_datafields&.any? { |f| f.code == "w" && f.value&.start_with?("g") }

          acc << extractor.collect_subfields(selected_datafields, spec).first
        end
      end  
    end
  end

  def get_filename
    (@settings.dig(:original_filename) || @settings.dig(:filename))
  end

  def add_filename
    lambda do |rec, acc|
      acc << get_filename
    end
  end

  def add_source_vocab
    lambda do |rec, acc|
      filename = get_filename || ""
      case
      when rec["040"] && rec["040"]["a"] == "DNLM"
        acc << "mesh"
      when rec["040"] && rec["040"]["e"] == "lcmpt"
        acc << "lcmpt"

      # For 040 $f values
      when rec["040"] && rec["040"]["f"] == "lcgft"
        acc << "lcgft"
      when rec["040"] && rec["040"]["f"] == "gsafd"
        acc << "gsafd"

      when rec["040"] && rec["040"]["f"] == "rbmscv"
        acc << "rbmscv"

      when rec["040"] && rec["040"]["f"] == "olacvggt"
        acc << "olacvggt"

      when rec["040"] && rec["040"]["f"] == "homoit"
        acc << "homoit"

      when rec["040"] && rec["040"]["f"] == "lcdgt"
        acc << "lcdgt"

      when rec["040"] && rec["040"]["f"] == "fast"
        acc << "fast"

        # For 024 $2 values
      when rec["024"] && rec["024"]["2"] == "aat"
        acc << "aat"

      when rec["024"] && rec["024"]["2"] == "tgm"
        acc << "tgm"

        # For 008/11 fixed field value
      when rec["008"]&.value && rec["008"].value[11] == "a" && rec["001"]&.value&.start_with?("sh")
        acc << "lcsh"

      when rec["100"] || rec["110"] || rec["111"] || rec["130"] || rec ["151"]
        acc << "lcnaf"
      end
    end  
  end

  def add_import_method
    lambda do |rec, acc|
      unless get_filename&.empty?
        acc << "MARC binary"
      end
    end
  end

  def extract_marc_subfields(subfields, options = {})
    lambda do |rec, acc|
      Traject::MarcExtractor.cached(subfields).collect_matching_lines(rec) do |field, spec, extractor|
        result = field.subfields.reduce("") { |value, sf|
          if spec.subfields.include? sf.code
            value += "$#{sf.code}#{sf.value}"
          else
            value += ""
          end
        }
        acc << result
      end
    end
  end
end
