<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="4.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">

  <param as="document-node()" name="P_GLOBAL_CONTEXT_ITEM" select="."/>

  <include href="../../lib/basic.xsl"/>

  <variable as="xs:integer*" name="PARTS_THAT_SHARE_A_STAFF" select="
      let $firstScoreDef := //scoreDef[not(preceding::scoreDef)]
      return
      $firstScoreDef//staffDef[descendant::layerDef[@type='part']]/@n"/>
     


  <variable as="xs:string*" name="CONTROL_EVENTS">
    <sequence select="doc('../../lib/lists/lists.xml')/id('controlEvents')/dme:item/data()"/>
  </variable>

  <template match="music//*[local-name() = $CONTROL_EVENTS]">
    <copy>
      <apply-templates select="@*"/>
      <call-template name="add.staff.layer"/>
      <apply-templates select="node()"/>
    </copy>
  </template>

  <template name="add.staff.layer">

    <variable as="xs:string*" name="startId" select="@startid"/>
    <variable as="element()?" name="reference" select="$P_GLOBAL_CONTEXT_ITEM/id(substring-after($startId, '#'))"/>

    <if test="not(@staff) and $reference">
      <variable as="xs:integer" name="staffValue" select="$reference/ancestor::staff/@n"/>
      <attribute name="staff" select="$staffValue"/>
    </if>
    <if test="not(@layer) and $reference">

      <variable as="xs:integer" name="layerValue" select="$reference/ancestor::layer/@n"/>
      <variable as="xs:integer" name="staffValue" select="$reference/ancestor::staff/@n"/>

      <if test="(@part[. = '%all'] => not()) and ($staffValue = $PARTS_THAT_SHARE_A_STAFF)">
        <attribute name="layer" select="$layerValue"/>
      </if>
    </if>


  </template>

</stylesheet>
