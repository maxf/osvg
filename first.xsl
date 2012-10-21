<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
               xmlns:p="http://lapin-bleu.net/osm2svg/ns"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               version="2.0"
               exclude-result-prefixes="#all">


  <xsl:strip-space elements = "*" />
  <xsl:output indent="yes"/>
  <xsl:key name="node-key" match="node" use="@id"/>
  <xsl:key name="way-key" match="way" use="@id"/>

  <xsl:variable name="params" select="document('params.xml')/p:params/p:param"/>


  <xsl:template match="osm|bounds|bound">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node"/>
  <xsl:template match="tag"/>
  <xsl:template match="way"/>
  <xsl:template match="relation"/>

  <xsl:template match="node[some $tag in tag satisfies (some $param in $params satisfies ($param/@type=$tag/@k and $param/@subtype=$tag/@v))]">
    <xsl:copy>
      <xsl:copy-of select="(@lat,@lon)"/>
      <xsl:copy-of select="(tag[@k='name'], tag[@k='place'])"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tag[some $param in $params satisfies $param/@type = current()/@k]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="way[some $tag in tag satisfies (some $param in $params satisfies ($param/@type=$tag/@k and $param/@subtype=$tag/@v))]">
    <xsl:copy>
      <xsl:for-each select="nd">
        <xsl:variable name="n" select="key('node-key',@ref)"/>
        <node lat="{$n/@lat}" lon="{$n/@lon}"/>
      </xsl:for-each>

      <xsl:apply-templates select="tag"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="relation[some $tag in tag satisfies (some $param in $params satisfies ($param/@type=$tag/@k and $param/@subtype=$tag/@v))]">
    <xsl:copy>
      <xsl:for-each select="member">
        <xsl:copy>
          <xsl:variable name="w" select="key('way-key',@ref)"/>
          <xsl:for-each select="$w/nd">
            <xsl:variable name="n" select="key('node-key',@ref)"/>
            <node lat="{$n/@lat}" lon="{$n/@lon}"/>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>
      <xsl:apply-templates select="tag"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
