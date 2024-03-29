
# Include custom traject macros
#

extend CentralizedMetadata::Macros::Custom

# Additional technical and local metadata fields added separately not through this file - ex. cm_created_at and cm_updated_at

to_field "cm_id", extract_marc("001", first: true), gsub(/\s+/, "")
to_field "cm_pref_label", extract_marc("100:110:111:130:147:148:150:151:155")
to_field "cm_var_label", extract_marc("400abcdfghjklmnopqrstv:410abcdfghjklmnoprstv:411acdefghklnpqstv:430adfghklmnoprstv:447acdgv:448av:450abgj:451agv:455av")
to_field "cm_source_vocab", add_source_vocab
to_field "cm_import_method", add_import_method
to_field "cm_filename", add_filename
to_field "cm_type", set_type
to_field "cm_see_also", extract_see_also
# to_field "cm_skos_exact_match", default("skip")
# to_field "cm_skos_close_match", default("skip")
to_field "cm_lc_class", extract_marc("053ab")
to_field "cm_narrower_term", extract_narrower_term
to_field "cm_broader_term", extract_broader_term
to_field "cm_use_subject", extract_use_subject
to_field "cm_undiff_name",  extract_undiff_name
to_field "cm_birth_date", extract_marc("046f")
to_field "cm_death_date", extract_marc("046g")
to_field "cm_establishment_date", extract_marc("046q")
to_field "cm_termination_date", extract_marc("046r")
to_field "cm_start_period", extract_marc("046s")
to_field "cm_end_period", extract_marc("046t")
to_field "cm_place_of_birth", extract_marc("370a")
to_field "cm_place_of_death", extract_marc("370b")
to_field "cm_associated_country", extract_marc("370c")
to_field "cm_residencehq", extract_marc("370e")
to_field "cm_other_associated_place", extract_marc("370f")
to_field "cm_field_activity", extract_marc("372a")
to_field "cm_associated_group", extract_marc("373a")
to_field "cm_occupation", extract_marc("374a")
to_field "cm_gender", extract_marc("375a")
to_field "cm_type_family", extract_marc("376a")
to_field "cm_prom_member", extract_marc("376b")
to_field "cm_heredity_title", extract_marc("376c")
to_field "cm_associated_language", extract_marc("377a")
to_field "cm_fuller_name", extract_marc("378q")
to_field "cm_type_corporate_body", extract_marc("368a")
to_field "cm_type_jurisdiction", extract_marc("368b")
to_field "cm_other_designation", extract_marc("368c")
to_field "cm_title_person", extract_marc("368d")
to_field "cm_content_type", extract_marc("336a")
to_field "cm_form_work", extract_marc("380a")
to_field "cm_medium_performance", extract_marc("382a")
to_field "cm_solist", extract_marc("382b")
to_field "cm_doubling_instrument", extract_marc("382d")
to_field "cm_alternative_medium_performance", extract_marc("382p")
to_field "cm_original_key", extract_original_key
to_field "cm_transposed_key", extract_marc("384|1*|a")
to_field "cm_music_num_designation", extract_marc_subfields("383abcde")
to_field "cm_audience_characteristics", extract_marc("385a")
to_field "cm_characteristics", extract_marc("386a")
to_field "cm_work_time_creation", extract_work_time_creation
to_field "cm_aggwork_time_creation", extract_marc("388|2*|a")
to_field "cm_work_language", extract_marc("100l:110l:111l:130l")
to_field "cm_notmusic_format", extract_marc("348a")
to_field "cm_beginning_date_created", extract_marc("046k")
to_field "cm_ending_date_created", extract_marc("046l")
to_field "cm_place_origin_work", extract_marc("370g")
to_field "cm_series_pubdates", extract_marc("640a")
to_field "cm_series_num_peculiar", extract_marc("641a")
to_field "cm_series_num_ex", extract_marc("642a")
to_field "cm_series_placepub", extract_marc_subfields("643abd")
to_field "cm_series_analysis", extract_marc_subfields("644abd")
to_field "cm_series_tracing_practice", extract_marc_subfields("645ad")
to_field "cm_series_classificaton_practice",extract_marc_subfields("646ad")
