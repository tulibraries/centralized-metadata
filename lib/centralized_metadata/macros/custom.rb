# frozen_string_literal: true
require "pry"

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

      when rec["150"]
        acc << "topical subject"

      when rec["151"]
        acc << "geographic subject"
      
      when rec["155"]
        acc << "genre"
      end
    end
  end

  def extract_see_also
    lambda do |rec, acc|
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av").collect_matching_lines(rec) do |field, spec, extractor|
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
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av").collect_matching_lines(rec) do |field, spec, extractor|
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
      Traject::MarcExtractor.cached("500abcdfghjklmnopqrstv:510abcdfghjklmnoprstv:511acdefghklnpqstv:530adfghklmnoprstv:547acdgv:548av:550abgj:551agv:555av").collect_matching_lines(rec) do |field, spec, extractor|
        broader_term_datafields = rec.fields.select { |f| f if extractor.interesting_tag?(f.tag) }
        selected_datafields = field if broader_term_datafields.include?(field)
        
        if selected_datafields&.any? { |f| f.code == "w" && f.value&.start_with?("g") }

          acc << extractor.collect_subfields(selected_datafields, spec).first
        end
      end  
    end
  end

  def add_filename
    lambda do |rec, acc|
      acc << @settings.dig(:original_filename) || @settings.dig(:filename)
    end
  end

  def add_source_vocab
    lambda do |rec, acc|
      filename = @settings.dig(:original_filename) || @settings.dig(:filename) || ""
      case
      when filename.include?("GNR")
        acc << "lcgft"

      when filename.include?("NAM") || filename.include?("TTL")
        acc << "lcnaf"

      when filename.include?("MSH")
        acc << "mesh"

      when filename.include?("SUB") && rec["008"].value[11] == "a"
        acc << "lcsh"

      when filename.include?("SUB") && rec["040"]&.subfields&.any? { |sf| sf.code == "f" && sf.value == "fast"}
        acc << "fast"
      end
    end  
  end  
end
