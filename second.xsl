<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="2.0" 
             xmlns="http://www.w3.org/2000/svg"
             xmlns:fn="http://www.w3.org/2005/xpath-functions"
             xmlns:p="http://lapin-bleu.net/osm2svg/ns"
             xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:variable name="scaling-factor" select="100000"/>


  <x:variable name="minlat"
              select="number(if (/osm/bounds) then /osm/bounds/@minlat else fn:replace(/osm/bound/@box,'([0-9.]+),[0-9.]+,[0-9.]+,[0-9.]+', '$1'))"/>

  <x:variable name="minlon"
              select="number(if (/osm/bounds) then /osm/bounds/@minlon else fn:replace(/osm/bound/@box,'[0-9.]+,([0-9.]+),[0-9.]+,[0-9.]+', '$1'))"/>

  <x:variable name="maxlat"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlat else fn:replace(/osm/bound/@box,'[0-9.]+,[0-9.]+,([0-9.]+),[0-9.]+', '$1'))"/>

  <x:variable name="maxlon"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlon else fn:replace(/osm/bound/@box,'[0-9.]+,[0-9.]+,[0-9.]+,([0-9.]+)', '$1'))"/>

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
      <x:apply-templates select="way"/>
      <x:apply-templates select="node"/>
    </svg>
  </x:template>

  <x:template match="osm/node[tag/@k='place']">
    <text x="{$scaling-factor * (@lon - $minlon)}" y="{ - $scaling-factor * (@lat - $maxlat)}" text-anchor="middle" class="place {tag[@k='place']/@v}"><x:value-of select="tag[@k='name']/@v"/></text>
  </x:template>

  <x:template match="way[tag[@k='highway']]">
    <x:variable name="subtype" select="tag[@k='highway']/@v"/>
    <polyline class="highway {$subtype}">
      <x:attribute name="points">
        <x:for-each select="node">
          <x:value-of select="concat($scaling-factor * (@lon - $minlon),',', - $scaling-factor * (@lat - $maxlat),' ')"/>
        </x:for-each>
      </x:attribute>
    </polyline>
  </x:template>

  <x:template match="way[tag[@k='landuse']]">
    <x:variable name="subtype" select="tag[@k='landuse']/@v"/>

    <!-- calculate the bounding box area, to check if this is big enough to display -->
    <x:variable name="longitudes" select="node/@lon"/>
    <x:variable name="latitudes" select="node/@lon"/>
    <x:variable name="area" select="(fn:max($longitudes) - fn:min($longitudes)) * (fn:max($latitudes) - fn:min($latitudes))"/>
    <x:if test="$area > $params/p:area-threshold * $total-area">
      <polyline class="landuse {$subtype}">
        <x:attribute name="points">
          <x:for-each select="node">
            <x:value-of select="concat($scaling-factor * (@lon - $minlon),',', - $scaling-factor * (@lat - $maxlat),' ')"/>
          </x:for-each>
        </x:attribute>
      </polyline>
    </x:if>
  </x:template>


</x:transform>

