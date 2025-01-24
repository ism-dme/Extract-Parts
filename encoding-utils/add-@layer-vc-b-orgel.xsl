<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="4.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">

  <include href="../lib/basic.xsl"/>
  <!--Change the number depending on the score.-->
  <variable as="xs:integer" name="staffNumber" select="7"/>

  <template match="*[@staff = $staffNumber]">
    <copy>
      <apply-templates select="@*"/>
      <attribute name="layer">
        <choose>
          <when test="self::harm">
            <value-of select="'3'"/>
          </when>
          <otherwise>
            <value-of select="'1 2 3'"/>
          </otherwise>
        </choose>
      </attribute>
      <apply-templates select="node()"/>

    </copy>


  </template>

</stylesheet>
