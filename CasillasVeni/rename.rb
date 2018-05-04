#!/usr/bin/env ruby -rfileutils -nl

old = $_
new = $_.gsub(/\d{8}_(\d{6})[^\/]*\.(jpg|json|snap)/, "\\1.\\2")
FileUtils.mv(old, new) unless old == new
#puts "mv #{old} #{new}" unless old == new
