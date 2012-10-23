<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="2.0" 
             xmlns="http://www.w3.org/2000/svg"
             xmlns:fn="http://www.w3.org/2005/xpath-functions"
             xmlns:p="http://lapin-bleu.net/osm2svg/ns"
             xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:variable name="scaling-factor" select="100000"/>


  <x:variable name="minlat"
              select="number(if (/osm/bounds) then /osm/bounds/@minlat else fn:replace(/osm/bound/@box,'([\-0-9.]+),[\-0-9.]+,[\-0-9.]+,[\-0-9.]+', '$1'))"/>

  <x:variable name="minlon"
              select="number(if (/osm/bounds) then /osm/bounds/@minlon else fn:replace(/osm/bound/@box,'[\-0-9.]+,([\-0-9.]+),[\-0-9.]+,[\-0-9.]+', '$1'))"/>

  <x:variable name="maxlat"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlat else fn:replace(/osm/bound/@box,'[\-0-9.]+,[\-0-9.]+,([\-0-9.]+),[\-0-9.]+', '$1'))"/>

  <x:variable name="maxlon"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlon else fn:replace(/osm/bound/@box,'[\-0-9.]+,[\-0-9.]+,[\-0-9.]+,([\-0-9.]+)', '$1'))"/>

  <x:variable name="width" select="$scaling-factor * ($maxlon - $minlon)"/>
  <x:variable name="height" select="$scaling-factor * ($maxlat - $minlat)"/>

  <x:variable name="total-area" select="$width * $height"/>

  <x:output indent="yes"/>


  <x:template match="/">
    <x:apply-templates/>
  </x:template>

  <x:variable name="params" select="document('params.xml')/p:params"/>
        


  <x:template match="osm">
    <x:processing-instruction name="xml-stylesheet" select="' type=&quot;text/css&quot; href=&quot;style.css&quot;'"/>
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="100%" height="100%" id="svgroot" preserveAspectRatio="none">
      <x:apply-templates select="relation"/>
      <x:apply-templates select="way[not(tag[@k='highway'])]"/>
      <x:apply-templates select="way[tag[@k='highway']]"><x:with-param name="mode" select="'border'"/></x:apply-templates>
      <x:apply-templates select="way[tag[@k='highway']]"><x:with-param name="mode" select="'fill'"/></x:apply-templates>
      <x:apply-templates select="node"/>
    </svg>
  </x:template>

  <!-- nodes for places (ie, labels on the map) -->
  <x:template match="osm/node[tag/@k='place']">
    <text x="{$scaling-factor * (@lon - $minlon)}" y="{ - $scaling-factor * (@lat - $maxlat)}" text-anchor="middle" class="place {tag[@k='place']/@v}"><x:value-of select="tag[@k='name']/@v"/></text>
  </x:template>

  <!-- highways (roads, motorways, etc) -->
  <x:template match="way[tag[@k='highway']]">
    <x:param name="mode" select="'fill'"/>
    <x:variable name="type" select="tag[@k='highway']/@k"/>
    <x:variable name="subtype" select="tag[@k=$type]/@v"/>
    <x:variable name="points" select="for $node in node return concat($scaling-factor * ($node/@lon - $minlon),',', - $scaling-factor * ($node/@lat - $maxlat),' ')"/>
    <polyline class="{$type} {$subtype}-{$mode}" points="{$points}"/>
  </x:template>


  <!-- areas -->
  <x:template match="way[tag[@k='landuse' or @k='leisure' or @k='waterway']]">
    <x:variable name="type" select="tag[@k='landuse' or @k='leisure' or @k='waterway']/@k"/>
    <x:variable name="subtype" select="tag[@k=$type]/@v"/>

    <!-- calculate the bounding box area, to check if this is big enough to display -->
    <x:variable name="longitudes" select="node/@lon"/>
    <x:variable name="latitudes" select="node/@lon"/>
    <x:variable name="area" select="(fn:max($longitudes) - fn:min($longitudes)) * (fn:max($latitudes) - fn:min($latitudes))"/>
    <x:if test="$area > $params/p:area-threshold * $total-area">
      <polyline class="{$type} {$subtype}">
        <x:attribute name="points">
          <x:for-each select="node">
            <x:value-of select="concat($scaling-factor * (@lon - $minlon),',', - $scaling-factor * (@lat - $maxlat),' ')"/>
          </x:for-each>
        </x:attribute>
      </polyline>
    </x:if>
  </x:template>

  <x:template match="relation[tag[@k='landuse' or @k='leisure' or @k='waterway']]">
    <x:variable name="type" select="tag[@k='landuse' or @k='leisure' or @k='waterway']/@k"/>
    <x:variable name="subtype" select="tag[@k=$type]/@v"/>


    <x:for-each select="member">
      <g>
        <!-- calculate the bounding box area, to check if this is big enough to display -->
        <x:variable name="longitudes" select="node/@lon"/>
        <x:variable name="latitudes" select="node/@lon"/>
        <x:variable name="area" select="(fn:max($longitudes) - fn:min($longitudes)) * (fn:max($latitudes) - fn:min($latitudes))"/>
        <x:if test="$area > $params/p:area-threshold * $total-area">
          <polyline class="{$type} {$subtype}">
            <x:attribute name="points">
              <x:for-each select="node">
                <x:value-of select="concat($scaling-factor * (@lon - $minlon),',', - $scaling-factor * (@lat - $maxlat),' ')"/>
              </x:for-each>
            </x:attribute>
          </polyline>
        </x:if>
      </g>
    </x:for-each>
  </x:template>


  <x:template match="relation[tag[@k='route']]">
    <x:variable name="type" select="tag[@k='route']/@k"/>
    <x:variable name="subtype" select="tag[@k=$type]/@v"/>

    <x:for-each select="member">
      <g>
        <polyline class="{$type} {$subtype}">
          <x:attribute name="points">
            <x:for-each select="node">
              <x:value-of select="concat($scaling-factor * (@lon - $minlon),',', - $scaling-factor * (@lat - $maxlat),' ')"/>
            </x:for-each>
          </x:attribute>
        </polyline>
      </g>
    </x:for-each>
  </x:template>

</x:transform>

