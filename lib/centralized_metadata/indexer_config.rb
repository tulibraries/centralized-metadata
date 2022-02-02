
to_field "id", extract_marc("001", first: true), strip
to_field "pref_label", extract_marc("100:110:111:130:147:148:150:151:155") 
to_field "var_label", extract_marc("400abcdfghjklmnopqrstv:410abcdfghjklmnoprstv:411acdefghklnpqstv:430adfghklmnoprstv:447acdgv:448av:450abgj:451agv:455av")
