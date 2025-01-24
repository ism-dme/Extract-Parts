<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="xs xd dme functx dita mei map array" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dita="http://dita-ot.sourceforge.net" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">

  <xd:doc>
    <xd:desc>
      <xd:p/>
    </xd:desc>
  </xd:doc>
  <template match="scoreDef[not(ancestor::app) (:special case K. 550:) and not(preceding::scoreDef)]" mode="step_one">
    <variable as="element()" name="delete.staffDefs">
      <apply-templates mode="process.staffDef" select="."/>
    </variable>
    <variable as="element()" name="clean.staffGrps">
      <apply-templates mode="m.adjust.staffGrps" select="$delete.staffDefs"/>
    </variable>
    <copy-of select="$clean.staffGrps"/>
  </template>


  <xd:doc>
    <xd:p>Processes staffDef depending if the whole staff is requested for extraction or one of the layers.</xd:p>
    <xd:p>Deletes staves (mei:staffDef) which do not match the requested part number.</xd:p>
  </xd:doc>
  <template match="staffDef" mode="process.staffDef" name="process.staffDef">
    <choose>
      <!--Split staff-->
      <when test="$REQUESTED_PARTS//dme:part[@staff = current()/@n]/@split">
        <call-template name="split.staffDef"/>
      </when>
      <!--One or more layerDefs-->
      <when test="
          some $staff in $REQ_PARTS_EXTRACT_LAYERS
            satisfies $staff = @n">
        <call-template name="resolve.layerDef"/>
      </when>
      <!--Whole staff-->
      <when test="
          some $staff in $REQ_PARTS_EXTRACT_STAVES
            satisfies $staff = @n">
        <!--        <call-template name="instrument.name.extracted.staff"/>-->
        <copy>
          <call-template name="renumber.staffdef"/>
          <apply-templates select="node()"/>
        </copy>
      </when>
      <!--Other staffDefs will be deleted.-->
    </choose>
  </template>


  <template name="resolve.layerDef">
    <copy>
      <call-template name="renumber.staffdef"/>
      <variable as="attribute(layer)" name="layerN" select="$REQUESTED_PARTS//dme:part[@staff eq current()/@n]/@layer"/>
      <attribute name="decls" select=".//layerDef[@n = $layerN]/@decls"/>
      
      <!--<message>
        <value-of select="@xml:id"/>
      </message>-->
      
      <!--TODO: Add @decls-->
      <call-template name="get.part.labels">
        <with-param as="element(layerDef)" name="pLayerDef" select="layerDef[@n = $layerN]" tunnel="yes"/>
        <with-param as="element(staffDef)" name="pStaffDef" select="." tunnel="yes"/>
      </call-template>
    </copy>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Generates new staffDef elements based on the number of the layerDef elements</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="split.staffDef">

    <variable as="element(mei:staffDef)" name="currentStaffDef" select="."/>

    <iterate select="layerDef">
      <element name="staffDef" namespace="http://www.music-encoding.org/ns/mei">

        <apply-templates select="$currentStaffDef/@*"/>
        <attribute name="decls" select="$currentStaffDef//layerDef[@n = current()/@n]/@decls"/>

        <variable as="xs:integer" name="newStaffNumber">
          <call-template name="get.new.staff.number">
            <with-param as="xs:integer" name="staffN" select="xs:integer($currentStaffDef/@n)"/>
            <with-param as="xs:integer" name="layerN" select="xs:integer(@n)"/>
          </call-template>
        </variable>

        <attribute name="n" select="$newStaffNumber"/>
        <attribute name="xml:id" select="$currentStaffDef/@xml:id || '_' || $newStaffNumber"/>

        <call-template name="get.part.labels">
          <with-param as="element(layerDef)" name="pLayerDef" select="." tunnel="yes"/>
          <with-param as="element(mei:staffDef)" name="pStaffDef" select="$currentStaffDef" tunnel="yes"/>
          <with-param as="xs:integer" name="pNewStaffDefNumber" select="$newStaffNumber"/>
        </call-template>

      </element>
    </iterate>

  </template>

  <xd:doc>
    <xd:desc>
      <xd:p>Copies attributes. Renumbers staffDef@n if required.</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="renumber.staffdef">
    <apply-templates select="@*"/>
    <if test="$USER_PARAMETERS//dme:renumberStaves = 'yes' or $REQUESTED_PARTS//@split">
      <attribute name="n" select="map:get($NEW_STAVES_NUMBERING, xs:integer(@n))"/>
    </if>
  </template>

  <xd:doc>
    <xd:desc>
      <xd:p>Empty and redundant staffGrps are deleted; @symbol is adjusted.</xd:p>
    </xd:desc>
  </xd:doc>
  <template match="staffGrp" mode="m.adjust.staffGrps">
    <choose>
      <!--Delete empty staffGrps-->
      <when test="not(descendant::staffDef)"/>
      <!--Delete redundant stafGrp. E.g. when extracting Violins there are one staffGrp for Violin I, II and one stafGrp for strings. When extracting Violin I, hte strings-staffGrp would be redundant:-->
      <!--   <staffGrp barthru="true" symbol="bracket" xml:id="staffGrp_04">
        <staffGrp symbol="brace" xml:id="staffGrp_05">
          <staffDef clef.line="2" clef.shape="G" decls="#instrVoice_11" dme.parts="11" doxml.id="d27e466" label.abbr="Vl. I" lines="5" n="7" xml:id="staffDef_P7">
            <label xml:id="label_P7">Violino I</label>
          </staffDef>
        </staffGrp>
      </staffGrp>-->
      <when test="parent::staffGrp and count(child::staffGrp/staffDef) = 1">
        <apply-templates mode="#current"/>
      </when>
      <!--If only one part is extracted (e.g. Oboe II out from Flauto, Oboi, Clarinetti), the bracket should be replaced 'none'.-->
      <when test="count(child::staffDef) = 1">
        <choose>
          <!--But: when multiple parts remains on the staff, @symbol should be preserved -->
          <when test="count(child::staffDef//descendant::layerDef) > 1">
            <copy>
              <apply-templates mode="#current" select="@*, node()"/>
            </copy>
          </when>
          <otherwise>
            <copy>
              <attribute name="symbol" select="'none'"/>
              <apply-templates mode="#current" select="@* except @symbol, node()"/>
            </copy>
          </otherwise>
        </choose>
      </when>
      <otherwise>
        <copy>
          <apply-templates mode="#current" select="@*, node()"/>
        </copy>
      </otherwise>
    </choose>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Returns new label text, e. g. "Clarinetti" => 'Clarinetto I'</xd:p>
    </xd:desc>
    <xd:param name="pLayerDef">mei:layerDef of the mei:layer to be extracted</xd:param>
    <xd:param name="pStaffDef">Current mei:staffDef.</xd:param>
    <xd:param name="pNewStaffDefNumber">New number of the created staff. Optional parameter. It is passed in the context of split staves feature only.</xd:param>
  </xd:doc>
  <template name="get.part.labels">
    <param name="pLayerDef" tunnel="yes"/>
    <param as="element(mei:staffDef)" name="pStaffDef" tunnel="yes"/>
    <param as="xs:integer?" name="pNewStaffDefNumber"/>

    <variable as="element()" name="itemPerfRes" select="
        let $perfResId := substring-after($pLayerDef/@decls, '#')
        return
          $P_GLOBAL_CONTEXT_ITEM/id($perfResId)"/>
    <variable as="xs:string" name="instrumentNamePerfRes" select="$itemPerfRes/text() => normalize-space()"/>
    <variable as="document-node()" name="instrumentsList" select="doc($P_LIB_PATH || '/lists/instruments.xml')"/>
    <!--    TODO: The variable may be not optional later.-->
    <variable as="element()?" name="itemInstrumentsList" select="$instrumentsList/id($instrumentNamePerfRes)"/>
    <variable as="xs:string" name="instrumentName" select="$itemInstrumentsList/dme:name[@xml:lang = $P_LANGUAGE]/text() => normalize-space()"/>
    <variable as="xs:string" name="instrumentNameAbbr" select="$itemInstrumentsList/dme:name[@xml:lang = $P_LANGUAGE]/@label.abbr => normalize-space()"/>

    <variable as="map(xs:string, item()*)?" name="transposition">
      <call-template name="get.instruments.transposition">
        <with-param name="itemPerfRes" select="$itemPerfRes"/>
        <with-param name="itemInstrumentsList" select="$itemInstrumentsList"/>
      </call-template>
    </variable>

    <variable as="xs:string" name="romanInteger">
      <call-template name="roman.integer"/>
    </variable>

    <variable as="xs:string?" name="newIdSuffix">
      <choose>
        <when test="$pNewStaffDefNumber instance of xs:integer">
          <value-of select="'_' || $pNewStaffDefNumber"/>
        </when>
        <otherwise>
          <value-of select="''"/>
        </otherwise>
      </choose>
    </variable>

    <label xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="xml:id" select="$pStaffDef/label/@xml:id || $newIdSuffix"/>
      <xsl:value-of select="$instrumentName || $romanInteger || $transposition?label"/>
    </label>

    <labelAbbr xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="xml:id" select="$pStaffDef/labelAbbr/@xml:id || $newIdSuffix"/>
      <xsl:value-of select="$instrumentNameAbbr || $transposition?labelAbbr"/>
    </labelAbbr>

  </template>

  <template name="get.instruments.transposition">
    <param as="element()" name="itemPerfRes"/>
    <param as="element()?" name="itemInstrumentsList"/>

    <choose>
      <when test="$itemPerfRes[@trans.diat and @trans.semi]">
        <variable as="element()" name="itemTransposition" select="$itemInstrumentsList/dme:transposition[@trans.semi = $itemPerfRes/@trans.semi and @trans.diat = $itemPerfRes/@trans.diat]"/>

        <variable as="element()" name="transpositionLabel" select="$itemTransposition/dme:label[@xml:lang = $P_LANGUAGE]"/>
        <!--TODO: The transpositionLable might be empty. Cf.    <item dme.db="b" loc.codedval="sd" xml:id="Basso">
      <name label.abbr="Bs" xml:lang="IT">Basso</name>
      <name label.abbr="Bs" xml:lang="DE">Kontrabass</name>
      <name label.abbr="Bs" xml:lang="EN">Double Bass</name>
      <transposition trans.diat="-7" trans.semi="-12"/>
    </item>-->

        <sequence select="
            map {
              'label': ' ' || $transpositionLabel/text() => normalize-space(),
              'labelAbbr': ' ' || $transpositionLabel/@label.abbr
            }"/>
      </when>
      <otherwise>
        <sequence select="map {}"/>
      </otherwise>
    </choose>
  </template>



  <xd:doc>
    <xd:desc>
      <xd:p>Maps arabic and roman integers.</xd:p>
    </xd:desc>
    <xd:param name="layerDefN"/>
  </xd:doc>
  <template name="roman.integer">
    <param name="pLayerDef" tunnel="yes"/>
    <param name="pStaffDef" tunnel="yes"/>

    <variable as="xs:boolean" name="sameTypeInstruments">
      <variable as="xs:integer" name="declsCount" select="$pStaffDef//layerDef/@decls => distinct-values() => count()"/>
      <sequence select="
          if ($declsCount > 1) then
            false()
          else
            true()"/>
    </variable>

    <variable as="map(xs:string, xs:string)?" name="romanIntegers" select="
        map {
          '1': 'I',
          '2': 'II',
          '3': 'III',
          '4': 'IV',
          '5': 'V',
          '6': 'VI',
          '7': 'VII',
          '8': 'VIII',
          '9': 'IX',
          '10': 'X'
        }
        "/>
    <choose>
      <when test="$sameTypeInstruments">
        <value-of select="' ' || map:get($romanIntegers, $pLayerDef/@n)"/>
      </when>
      <otherwise>
        <value-of select="()"/>
      </otherwise>
    </choose>

  </template>


</stylesheet>
