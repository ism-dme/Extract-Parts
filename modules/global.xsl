<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">


  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template name="perform.extraction">

    <call-template name="create.message.extracting.parts"/>

    <variable name="extractedEvents">
      <apply-templates mode="step_one" select="$P_GLOBAL_CONTEXT_ITEM//mei:music"/>
    </variable>

    <variable name="extractedControlEvents">

      <choose>
        <when test="$SHRINK_MEASURES">

          <variable as="element()" name="multiRestMeasures">
            <call-template name="calculate.multirest.measures">
              <with-param name="pDocNode" select="$extractedEvents"/>
            </call-template>
          </variable>

          <apply-templates mode="step_two" select="$extractedEvents">
            <with-param as="element()?" name="pMultiRestMeasures" select="$multiRestMeasures" tunnel="yes"/>
          </apply-templates>

        </when>
        <otherwise>
          <apply-templates mode="step_two" select="$extractedEvents"/>
        </otherwise>
      </choose>

    </variable>


    <variable name="output">
      <mei xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:copy-of select="mei:mei/@*, .//mei:meiHead"/>
        <xsl:copy-of select="$extractedControlEvents"/>
      </mei>
    </variable>

    <!--DEBUG-->
    <!--     <variable as="xs:string" name="meiFileName" select="tokenize(base-uri(), '/')[last()]"/>
    <variable name="outputPath" select="$P_OUTPUT_PATH || substring-before($meiFileName, '.') || '_' || string-join($PARTS_TO_EXTRACT_MSG, '-') || '_extractedControlEvents' ||  '.mei'"/>
    <result-document href="{$outputPath}" indent="yes" method="xml">
      <mei  meiversion="5.0" xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:copy-of select="$extractedControlEvents"/>
      </mei>
    </result-document>-->

    <!--Used for XSpec-->
    <choose>
      <when test="$P_XSPEC_TEST or $P_OVERWRITE_FILE">
        <copy-of select="$output"/>
      </when>
      <otherwise>
        <variable as="xs:string" name="meiFileName" select="tokenize(base-uri(), '/')[last()]"/>
        <variable name="outputPath" select="$P_OUTPUT_PATH || substring-before($meiFileName, '.') || '_' || string-join($PARTS_TO_EXTRACT_MSG, '-') || '.mei'"/>
        <result-document href="{$outputPath}" indent="yes" method="xml">
          <copy-of select="$output"/>
        </result-document>
        <message>The output file was written to <value-of select="resolve-uri($outputPath)"/></message>
      </otherwise>
    </choose>
  </template>

  <xd:doc>
    <xd:desc>
      <xd:p>Returns configuration XML.</xd:p>
    </xd:desc>
  </xd:doc>
  <template as="element(dme:parameters)" name="configXml">
    <sequence select="doc($CONFIG_PATH)/dme:parameters"/>
  </template>


  <xd:doc>
    <xd:desc/>
    <xd:param name="id"/>
  </xd:doc>
  <template name="get.config.items">
    <param as="xs:string" name="id"/>
    <copy-of select="doc($P_LIB_PATH || '/lists/lists.xml')/id($id)/dme:item/data()"/>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Outputs the layer number which is supposed to be extracted for a given staff number.</xd:p>
    </xd:desc>
    <xd:param name="staffN">staff number</xd:param>
  </xd:doc>
  <function as="xs:string" name="dme:requested-layer">
    <param as="xs:integer" name="staffN"/>
    <sequence select="$REQUESTED_PARTS//dme:part[@staff = $staffN]/@layer/xs:string(.)"/>
  </function>


  <xd:doc>
    <xd:desc>
      <xd:p>Adds attributes to the XML passed as P_REQUESTED_PARTS.</xd:p>
      <xd:p>dme:parts@allPartsRequested: Specifies whether the requested parts match all available staves in the MEI. In this case, the file would not be processed at all.</xd:p>
      <xd:p>dme:parts@available: This attribute is calculated for each dme:part element. It defines whether the rquested dme:parts@staff is available in the current MEI.</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="enhance.requested.parts">
    <variable as="xs:integer+" name="availableStaves">
      <try>
        <sequence select="$SCORE_DEF//mei:staffDef/@n ! xs:integer(.)"/>
        <catch>
          <message>The file does not contain any staves!</message>
        </catch>
      </try>
    </variable>

    <variable as="element(dme:parts)" name="requestedParts" select="$USER_PARAMETERS//dme:parts"/>

    <sequence>
      <dme:parts>
        <attribute name="allPartsRequested">
          <choose>
            <when test="$requestedParts//dme:part/@layer or $requestedParts//dme:part/@split">
              <value-of select="'no'"/>
            </when>
            <otherwise>
              <value-of select="
                  if (functx:sequence-deep-equal($requestedParts//dme:part/@staff ! xs:integer(.), $availableStaves)) then
                    'yes'
                  else
                    'no'"/>
            </otherwise>
          </choose>
        </attribute>

        <iterate select="$requestedParts/*">
          <copy>
            <attribute name="available">
              <choose>
                <when test="functx:is-value-in-sequence(@staff, $availableStaves)">yes</when>
                <otherwise>no</otherwise>
              </choose>
            </attribute>
            <apply-templates select="@*"/>
          </copy>
        </iterate>
      </dme:parts>

    </sequence>
  </template>

  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template name="create.message.extracting.parts">

    <!--TODO: maybe refactor this to a function as the only difference is @available[. = 'yes|no']-->

    <variable as="xs:string*" name="notAvailableParts" select="
        for $part in $REQUESTED_PARTS//dme:part[@available[. = 'no']]
        return
          '(' || string-join(($part/@staff, $part/@layer), '-') || ')'"/>

    <message>Extracting requested parts <value-of select="string-join($PARTS_TO_EXTRACT_MSG, ', ')"/>. <if test="$REQUESTED_PARTS//dme:part[@available[. = 'no']]">Note that the following requested staves are not available in the current MEI: <value-of select="string-join($notAvailableParts, ', ')"/>.</if>
    </message>
  </template>

  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template name="create.message.parts.nonavailable">
    <!--TODO: add here info for requested layer-->
    <message><value-of select="'The requested part(s) ' || string-join($PARTS_TO_EXTRACT_MSG, ', ') || 'is/are not available in the MEI file or no parts were requested!'"/>. NB: No extraction was performed.</message>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Returns a map. The key is the original staffDef@n, the value is the new staffDef@n with respect to the new scoring.</xd:p>
      <xd:p>The number of split staves is calculated dynamically from the number of layerDefs of the staffDef in question.</xd:p>
    </xd:desc>
  </xd:doc>
  <template as="map(xs:integer, xs:integer)" name="new.staves.numbering">
    <map>
      <iterate select="$REQUESTED_PARTS//dme:part">
        <param as="xs:integer" name="pCounter" select="1"/>

        <variable as="xs:integer" name="preceedingSiblingCount">
          <variable as="element(dme:part)?" name="precedingSibling" select="(preceding-sibling::dme:part)[last()]"/>
          <choose>
            <when test="$precedingSibling[@split]">
              <sequence select="$SCORE_DEF//staffDef[@n = $precedingSibling/@staff]//layerDef => count()"/>
            </when>
            <otherwise>
              <sequence select="count($precedingSibling)"/>
            </otherwise>
          </choose>
        </variable>

        <variable as="xs:integer" name="newCount" select="$preceedingSiblingCount + $pCounter"/>
        <map-entry key="xs:integer(@staff)" select="$newCount"/>
        <next-iteration>
          <with-param as="xs:integer" name="pCounter" select="$newCount"/>
        </next-iteration>
      </iterate>
    </map>
  </template>

  <xd:doc>
    <xd:desc>Adds suffix to the current @xml:id. This is needed to avoid id duplicates when splitting staves.</xd:desc>
    <xd:param name="currentLayerN"/>
  </xd:doc>
  <template match="@xml:id" mode="adjustIdsForSplitElements">
    <param as="xs:integer" name="pCurrentLayerN" tunnel="yes"/>
    <attribute name="xml:id" select=". || '_' || string($pCurrentLayerN)"/>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Calculates the new staff number, whem staves are extracted or split.</xd:p>
    </xd:desc>
    <xd:param name="staffN"/>
    <xd:param name="layerN"/>
  </xd:doc>
  <template as="xs:integer" name="get.new.staff.number">
    <param as="xs:integer" name="staffN"/>
    <param as="xs:integer?" name="layerN"/>
    <!--DEBUG-->
    <!--<message>$staffN: <value-of select="$staffN"/>, $layerN: <value-of select="$layerN"/></message>-->

    <choose>
      <when test="$RENUMBER_STAVES">

        <variable as="xs:integer" name="newFirstStaffDefNumber" select="map:get($NEW_STAVES_NUMBERING, $staffN)"/>
        <choose>
          <when test="$REQUESTED_PARTS//dme:part[@staff = $staffN]/@split => not()">
            <sequence select="$newFirstStaffDefNumber"/>
          </when>
          <!--First staff to split is stored in the map.-->
          <when test="$layerN = 1">
            <sequence select="$newFirstStaffDefNumber"/>
          </when>
          <otherwise>
            <!-- Other staves have to be calculated-->
            <sequence select="
                let $indexOfLayer :=
                xs:integer($layerN)
                return
                  $indexOfLayer + $newFirstStaffDefNumber - 1"/>
          </otherwise>
        </choose>
      </when>
      <otherwise>
        <sequence select="$staffN"/>
      </otherwise>
    </choose>

  </template>
  
  <template match="pb|sb" mode="step_one"/>
    
  
  

</stylesheet>
