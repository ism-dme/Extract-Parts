<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">


  <include href="lib/basic.xsl"/>
  <include href="modules/global.xsl"/>
  <include href="modules/scoreDef.xsl"/>
  <include href="modules/events.xsl"/>
  <include href="modules/controlEvents.xsl"/>
  <include href="lib/functions/functx-1.0-doc-2007-01.xsl"/>
  <include href="lib/functions/functions_DIME.xsl"/>


  <!--Used for XSpec-->
  <param as="document-node()" name="P_GLOBAL_CONTEXT_ITEM" select="."/>
  <param name="P_USER_PARAMETERS">
    <call-template name="configXml"/>
  </param>
  <param as="xs:string" name="P_LANGUAGE" select="'IT'"/>
  <param as="xs:boolean" name="P_OVERWRITE_FILE" select="false()"/>
  <param as="xs:string" name="P_OUTPUT_PATH" select="'./'"/> 
  <param as="xs:boolean" name="P_SHRINK_MEASURES" select="true()"/>
  <param as="xs:boolean" name="P_XSPEC_TEST" select="false()"/>



  <!--static-base-uri() is needed for the compiled Saxon SEF files, when relocatable.-->
  <param name="P_LIB_PATH" select="resolve-uri('lib', static-base-uri())"/>
  <variable as="xs:anyURI" name="CONFIG_PATH" select="resolve-uri('config/config.xml', static-base-uri())"/>


  <variable as="document-node()" name="USER_PARAMETERS">
    <choose>
      <when test="$P_USER_PARAMETERS instance of document-node()">
        <sequence select="$P_USER_PARAMETERS"/>
      </when>
      <when test="$P_USER_PARAMETERS instance of element()">
        <document>
          <sequence select="$P_USER_PARAMETERS"/>
        </document>
      </when>
      <otherwise>
        <sequence select="parse-xml($P_USER_PARAMETERS)"/>
      </otherwise>
    </choose>
  </variable>
  <variable as="element(dme:parts)" name="REQUESTED_PARTS">
    <call-template name="enhance.requested.parts"/>
  </variable>
  <variable as="xs:integer*" name="REQ_PARTS_ALL_STAVES" select="$REQUESTED_PARTS//@staff/xs:integer(.)"/>
  <variable as="xs:integer*" name="REQ_PARTS_EXTRACT_STAVES" select="$REQUESTED_PARTS//dme:part[not(@layer)]/@staff/xs:integer(.)"/>
  <variable as="xs:integer*" name="REQ_PARTS_EXTRACT_LAYERS" select="$REQUESTED_PARTS//dme:part[@layer]/@staff/xs:integer(.)"/>
  <variable as="element(mei:scoreDef)" name="SCORE_DEF" select="$P_GLOBAL_CONTEXT_ITEM//scoreDef[not(preceding::scoreDef)]"/>
  <variable as="map(xs:integer, xs:integer)" name="NEW_STAVES_NUMBERING">
    <call-template name="new.staves.numbering"/>
  </variable>
  <variable as="xs:string*" name="PARTS_TO_EXTRACT_MSG" select="
      for $part in $REQUESTED_PARTS//dme:part[@available[. = 'yes']]
      return
        let $split := if ($part[@split = 'yes'])
        then
          '-split'
        else
          ''
        return
          '(' || string-join(($part/@staff, $part/@layer), '-') || $split
          || ')'
      "/>
  <variable as="xs:boolean" name="SHRINK_MEASURES">
    <variable as="xs:boolean" name="onePartRequested" select="count($REQUESTED_PARTS//dme:part/@available[. = 'yes']) eq 1"/>
    <sequence select="$onePartRequested and $P_SHRINK_MEASURES"/>
  </variable>

  <variable as="xs:boolean" name="RENUMBER_STAVES" select="$REQUESTED_PARTS//@split or $USER_PARAMETERS//dme:renumberStaves[. = 'yes']"/>

  <variable as="xs:boolean" name="EXTRACT_MULTIPLE_PARTS" select="count($REQUESTED_PARTS//dme:part/@available[. = 'yes']) > 1"/>
  <variable as="xs:boolean" name="DEBUG" select="false()"/>
  <variable as="map(xs:integer, xs:boolean)+" name="PARTS_THAT_SHARE_A_STAFF">
    <map>
      <iterate select="$SCORE_DEF//staffDef">

        <map-entry key="xs:integer(@n)" select="
            if (descendant::layerDef[@type = 'part']) then
              true()
            else
              false()"> </map-entry>

      </iterate>
    </map>
  </variable>




  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template match="/" name="main">
    <choose>
      <when test="$REQUESTED_PARTS/@allPartsRequested[. = 'yes']">
        <message>No extraction performed as all parts are selected!</message>
      </when>
      <when test="$REQUESTED_PARTS//dme:part/@available[. = 'yes']">
        <call-template name="perform.extraction"/>
      </when>
      <otherwise>
        <if test="$P_XSPEC_TEST or $P_OVERWRITE_FILE">
          <copy-of select="."/>
        </if>
        <call-template name="create.message.parts.nonavailable"/>
      </otherwise>
    </choose>
  </template>

</stylesheet>
