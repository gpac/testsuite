# MP4Box -diso puts the senc FullBoxInfo on the line following its box.
/<TrackEncryptionBox / {
 tenc_count++
 if (index($0, "flags=\"0x" tenc "\"") == 0) {
  print "Unexpected tenc flags: " $0 > "/dev/stderr"
  failed = 1
 }
}
/<SampleGroupDescriptionBox .*grouping_type="seig"/ { sgpd++ }
/<SampleGroupBox .*grouping_type="seig"/ { sbgp++ }
/<SampleEncryptionBox / { in_senc = 1; senc_count++; next }
in_senc && /<FullBoxInfo / {
 if (index($0, "Version=\"" senc_version "\"") == 0 || index($0, "Flags=\"0x" senc_flags "\"") == 0) {
  print "Unexpected senc version or flags: " $0 > "/dev/stderr"
  failed = 1
 }
 in_senc = 0
}
END {
 if (tenc_count != 1 || !senc_count || in_senc || (seig == "yes" && (!sgpd || !sbgp)) || (seig == "no" && (sgpd || sbgp))) {
  print "Missing or unexpected tenc, senc, or seig boxes" > "/dev/stderr"
  failed = 1
 }
 exit failed
}
