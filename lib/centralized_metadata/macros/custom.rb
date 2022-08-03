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

  def set_type
    lambda do |rec, acc|

      case
      when rec["100"]&.indicator1 != "3" &&
          rec["100"]&.subfields&.none? { |sf| sf.code == "t" }

        acc << "personal name"
      when  rec["110"]&.subfields&.none? { |sf| sf.code == "t" }

        acc << "corporate name"
      when  rec["111"]&.subfields&.none? { |sf| sf.code == "t" }

        acc << "conference name"
      when  rec["100"]&.subfields&.any? { |sf| sf.code == "t" } ||
        rec["110"]&.subfields&.any? { |sf| sf.code == "t" }  ||
        rec["111"]&.subfields&.any? { |sf| sf.code == "t" }

        acc << "name-title work"
      end
    end
  end
end
