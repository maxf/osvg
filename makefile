map.svg: map2.osm second.xsl params.xml
	java -Xmx2048m -jar saxon.jar -t -s:map2.osm -xsl:second.xsl -o:$@

map2.osm: map.osm first.xsl params.xml
	java -Xmx2048m -jar saxon.jar -t -s:map.osm -xsl:first.xsl -o:map2.osm


