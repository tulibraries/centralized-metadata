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
end
