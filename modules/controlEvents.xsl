<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">

  <variable as="xs:string*" name="CONTROL_EVENTS">
    <call-template name="get.config.items">
      <with-param name="id" select="'controlEvents'"/>
    </call-template>
  </variable>



  <template match="music//*[local-name() = $CONTROL_EVENTS]" mode="step_two">
    <param as="xs:integer?" name="pVariantsIteration" tunnel="yes"/>
    <if test="$DEBUG">
      <message>Template@match="music//*[local-name() = $CONTROL_EVENTS]" <value-of select="@xml:id"/>
      </message>
    </if>

    <variable as="xs:integer?" name="staffN">
      <!--@staff is mandatory, but the check is performed later.-->
      <sequence select="xs:integer(@staff)"/>
    </variable>

    <variable as="element()" name="controlEvent" select="."/>

    <choose>
      <when test="not(@staff)">
        <message>The element <value-of select="@xml:id"/> does not have mandatory @staff attribute. Therefore, it is copied but not processed.</message>
      </when>
      <when test="@part[. = '%all']">

        <!--Delete lower fermata which applies to the whole score, when extracting 1 part.-->
        <if test="(self::fermata[@place = 'below'] and not($EXTRACT_MULTIPLE_PARTS)) => not()">
          <call-template name="create.controlevent">
            <with-param as="xs:boolean" name="pSplit" select="false()"/>
            <with-param as="element()" name="pControlEvent" select="."/>
          </call-template>
        </if>

      </when>
      <when test="not(@layer) and map:get($PARTS_THAT_SHARE_A_STAFF, xs:integer(@staff))">
        <message>The element <value-of select="@xml:id"/> does not have mandatory @layer attribute. Therefore, it is copied but not processed.</message>
        <copy-of select="."/>
      </when>
      <!--Split staves-->
      <when test="$REQUESTED_PARTS//dme:part[@staff = $staffN and @split]">

        <choose>
          <when test="@type = 'staff'"/>

          <otherwise>
            <variable as="xs:string+" name="pointedLayers" select="tokenize(@layer, '\s+')"/>

            <choose>
              <when test="ancestor::supplied | ancestor::app | ancestor::choice">
                <call-template name="create.controlevent">
                  <with-param as="xs:boolean" name="pSplit" select="true()"/>
                  <with-param as="element()" name="pControlEvent" select="$controlEvent"/>
                  <with-param as="xs:integer" name="pLayerNumber" select="$pVariantsIteration"/>
                </call-template>
              </when>
              <otherwise>
                <iterate select="$pointedLayers">
                  <call-template name="create.controlevent">
                    <with-param as="xs:boolean" name="pSplit" select="true()"/>
                    <with-param as="element()" name="pControlEvent" select="$controlEvent"/>
                    <with-param as="xs:integer" name="pLayerNumber" select="xs:integer(.)"/>
                  </call-template>
                </iterate>
              </otherwise>
            </choose>
          </otherwise>
        </choose>

      </when>
      <!--Extract layer.-->
      <when test="$staffN = $REQ_PARTS_EXTRACT_LAYERS">
        <variable as="xs:string" name="reqLayer" select="dme:requested-layer($staffN)"/>

        <choose>
          <!--Delete element.-->
          <when test="not(contains(@layer, $reqLayer)) or (@type = 'staff')"/>
          <otherwise>
            <call-template name="create.controlevent">
              <with-param as="xs:boolean" name="pSplit" select="false()"/>
              <with-param as="element()" name="pControlEvent" select="."/>
              <!--              <with-param as="xs:integer" name="pLayerNumber" select="."/>-->
            </call-template>
          </otherwise>
        </choose>
      </when>
      <!--Extract staff.-->
      <when test="$staffN = $REQ_PARTS_EXTRACT_STAVES">
        <copy>
          <apply-templates select="@*"/>

          <variable as="xs:integer" name="newStaffNumber">
            <call-template name="get.new.staff.number">
              <with-param as="xs:integer" name="staffN" select="@staff"/>
            </call-template>
          </variable>
          <attribute name="staff" select="$newStaffNumber"/>
          <apply-templates select="node()"/>
        </copy>
      </when>
      <otherwise/>
    </choose>
  </template>



  <template name="create.controlevent">
    <param as="element()" name="pControlEvent"/>
    <param as="xs:boolean" name="pSplit"/>
    <param as="xs:integer?" name="pLayerNumber"/>


    <element name="{$pControlEvent/local-name()}" namespace="http://www.music-encoding.org/ns/mei">

      <if test="$DEBUG">
        <message>Template@name="create.controlevent" <value-of select="$pControlEvent/@xml:id"/>
        </message>
      </if>

      <variable as="xs:boolean" name="isDir" select="$pControlEvent/local-name() = 'dir'"/>

      <apply-templates select="$pControlEvent/@*[not(local-name() = ('startid', 'endid', 'curvedir', 'layer', 'place', 'part'))], $pControlEvent/@place[not($isDir)]"/>

      <!--Update @xml:id when split staves.-->
      <if test="$pSplit">
        <apply-templates mode="adjustIdsForSplitElements" select="$pControlEvent/@xml:id">
          <with-param as="xs:integer" name="pCurrentLayerN" select="$pLayerNumber" tunnel="yes"/>
        </apply-templates>
      </if>

      <variable as="xs:integer" name="newStaffNumber">
        <call-template name="new.staff.number.controlevents">
          <with-param as="element()" name="pControlEvent" select="$pControlEvent"/>
          <with-param as="xs:integer?" name="pCurrentLayerN" select="$pLayerNumber"/>
        </call-template>
      </variable>

      <attribute name="staff" select="$newStaffNumber"/>

      <call-template name="update.pointers">
        <with-param as="element()" name="pControlEvent" select="$pControlEvent"/>
        <with-param as="xs:integer" name="newStaffNumber" select="$newStaffNumber"/>
      </call-template>

      <if test="$pControlEvent/@part[. = '%all'] and $EXTRACT_MULTIPLE_PARTS">
        <apply-templates select="$pControlEvent/@part"/>
      </if>

      <apply-templates select="$pControlEvent/node()"/>
    </element>

  </template>


  <template name="update.pointers">
    <param as="element()" name="pControlEvent"/>
    <param as="xs:integer" name="newStaffNumber"/>

    <if test="$pControlEvent/@startid | $pControlEvent/@endid">

      <variable as="map(xs:string, xs:string)*" name="refs">
        <call-template name="get.references">
          <with-param as="element()" name="pControlEvent" select="$pControlEvent"/>
          <with-param as="xs:integer" name="pNewStaffN" select="$newStaffNumber"/>
        </call-template>
      </variable>


      <variable as="xs:boolean" name="multipleReferences">
        <variable as="xs:integer+" name="values">
          <iterate select="map:keys($refs)">
            <choose>
              <when test="count(map:get($refs, current()) => tokenize(',')) > 1">
                <sequence select="1"/>
              </when>
              <otherwise>
                <sequence select="0"/>
              </otherwise>
            </choose>
          </iterate>
        </variable>

        <sequence select="
            if (sum($values) > 0) then
              true()
            else
              false()"/>
      </variable>

      <choose>
        <when test="$multipleReferences">
          <!--TODO: See old template@name="clone.node.startid" -->
          <message><value-of select="$pControlEvent/@xml:id"/> points to multiple references. No @startid/@endid update perfomed!</message>
        </when>
        <when test="($refs?startid = '') and ($pControlEvent/local-name() = 'dynam')">
          <call-template name="startid2tstamp"/>
        </when>
        <otherwise>
          <for-each select="map:keys($refs)">
            <variable name="key" select="."/>
            <if test="$pControlEvent/@*[local-name() = $key]">
              <attribute name="{.}" select="
                  let $val := map:get($refs, .)
                  return
                    '#' || $val"/>
            </if>
          </for-each>

        </otherwise>
      </choose>
    </if>
  </template>


  <template name="new.staff.number.controlevents">
    <param as="element()" name="pControlEvent"/>
    <param as="xs:integer?" name="pCurrentLayerN"/>

    <choose>
      <when test="$pControlEvent[@part = '%all']">
        <choose>
          <when test="($pControlEvent/local-name() = ('dir', 'tempo')) or (($pControlEvent/local-name() = 'fermata') and $pControlEvent/@place[. = 'above'])">
            <sequence select="$pControlEvent/ancestor::measure//staff/@n => min() => xs:integer()"/>
          </when>
          <when test="($pControlEvent/local-name() = 'fermata') and $pControlEvent/@place[. = 'below']">
            <sequence select="$pControlEvent/ancestor::measure//staff/@n => max() => xs:integer()"/>
          </when>
        </choose>
      </when>
      <otherwise>
        <call-template name="get.new.staff.number">
          <with-param as="xs:integer" name="staffN" select="$pControlEvent/@staff"/>
          <with-param as="xs:integer?" name="layerN" select="xs:integer($pCurrentLayerN)"/>
        </call-template>
      </otherwise>
    </choose>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>For fermatas without @staff attribute, the value is retrieved from the reference.</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="get.fermata.staff">
    <variable as="element()?" name="refElement">
      <variable as="xs:string" name="startidPointer" select="substring-after(@startid, '#')"/>
      <sequence select="$P_GLOBAL_CONTEXT_ITEM/id($startidPointer)"/>
    </variable>
    <sequence select="$refElement/ancestor::staff/@n cast as xs:integer"/>
  </template>


  <template name="get.references">
    <param as="element()" name="pControlEvent"/>
    <param as="xs:integer" name="pNewStaffN"/>

    <variable as="element()" name="currentMeiBody" select="$pControlEvent/ancestor::body"/>

    <map>
      <for-each select="$pControlEvent/@startid, $pControlEvent/@endid">
        <variable as="element()?" name="reference" select="$P_GLOBAL_CONTEXT_ITEM/id(substring-after(current(), '#'))"/>

        <choose>
          <when test="$reference instance of element()">

            <variable as="attribute(xml:id)" name="measureId" select="$reference/ancestor::measure/@xml:id"/>

            <variable as="element(staff)" name="newStaff" select="$currentMeiBody/id($measureId)//staff[@n = $pNewStaffN]"/>
            <variable as="attribute(tstamp)" name="tstamp" select="$reference/@tstamp"/>

            <!--DEBUG-->
            <!--<message><value-of select="."></value-of></message>-->
            <variable as="attribute(xml:id)*" name="newReferences">
              <choose>

                <when test="$reference/ancestor::*[self::choice or self::app]">
                  <variable as="element()" name="variantsElement" select="($reference/ancestor::*[self::choice or self::app])[last()]"/>

                  <!--TODO: Relying on the variantID works only when the ControlEvent is attached to one layer only. The handling of other cases should be clarified. dme/dime/tools/extract-parts#92-->
                  <variable as="attribute(xml:id)" name="variantID" select="$variantsElement/*[.//*[@xml:id = $reference/@xml:id]]/@xml:id"/>

                  <sequence select="
                      $newStaff//id($variantID)//node()[@tstamp = $tstamp]/@xml:id"/>
                </when>
                <otherwise>
                  <sequence select="
                      $newStaff//node()[@tstamp = $tstamp]/@xml:id"/>
                </otherwise>
              </choose>

            </variable>


            <map-entry key="local-name(.)" select="string-join(($newReferences), ',')"/>
          </when>
          <otherwise>
            <message>No reference found for @<value-of select="./name()"/>="<value-of select="."/>"!</message>
            <map-entry key="local-name(.)" select="'NA'"/>
          </otherwise>
        </choose>


      </for-each>
    </map>
  </template>


  <template name="startid2tstamp">
    <variable as="xs:string" name="startidPointer" select="substring-after(@startid, '#')"/>
    <variable as="element()" name="reference" select="$P_GLOBAL_CONTEXT_ITEM/id($startidPointer)"/>
    <attribute name="tstamp" select="$reference/@tstamp"/>
  </template>


  <template match="measure/*[(self::supplied or self::app or self::choice) and descendant::*[local-name() = $CONTROL_EVENTS]]" mode="step_two">
    <variable as="xs:string*" name="layerN" select=".//@layer => distinct-values()"/>
    <variable as="xs:string*" name="staffN" select=".//@staff => distinct-values()"/>
    <variable as="xs:boolean" name="partAll" select=".//@part[. = '%all'] => boolean()"/>
    <variable as="element()" name="matchedElement" select="."/>

    <if test="$DEBUG">
      <message>Template@match="measure/*[(self::supplied or self::app or self::choice) and descendant::*[local-name() = $CONTROL_EVENTS]]": <value-of select="@xml:id"/> matched! </message>
    </if>

    <choose>
      <when test="not(count($staffN) eq 1)">
        <message>Descendants of <value-of select="@xml:id"/> either do not contain the mandatory @staff attribute or have different @staff values. The element is not processed!</message>
      </when>
      <when test="$REQUESTED_PARTS//dme:part[@staff = $staffN and @split]">
        <choose>
          <!-- TODO: Add tests.-->
          <when test="(count($layerN) eq 0) and $partAll">
            <copy>
              <apply-templates mode="#current" select="@*, node()"> </apply-templates>
            </copy>
          </when>
          <when test="not(count($layerN) eq 1)">
            <message>Descendants of <value-of select="@xml:id"/> either do not contain the mandatory @layer attribute or have different @layer values. The element is not processed!</message>
          </when>
          <otherwise>
            <iterate select="tokenize($layerN, '\s+')">
              <variable as="xs:integer" name="currentLayer" select="xs:integer(.)"/>

              <!--          <variable as="xs:string" name="currentLayerValye" select="."/>-->
              <element name="{$matchedElement/local-name()}" namespace="http://www.music-encoding.org/ns/mei">
                <apply-templates select="$matchedElement/@*"/>
                <!--Add suffix to @xml:id-->
                <apply-templates mode="adjustIdsForSplitElements" select="$matchedElement/@xml:id">
                  <with-param name="pCurrentLayerN" select="$currentLayer" tunnel="yes"/>
                </apply-templates>

                <choose>
                  <when test="$matchedElement/self::choice | $matchedElement/self::app">
                    <iterate select="$matchedElement/*">
                      <variable as="element()" name="currentIterationElement" select="."/>
                      <element name="{local-name()}" namespace="http://www.music-encoding.org/ns/mei">
                        <apply-templates select="$currentIterationElement/@*"/>
                        <!--Add suffix to @xml:id-->
                        <apply-templates mode="adjustIdsForSplitElements" select="$currentIterationElement/@xml:id">
                          <with-param name="pCurrentLayerN" select="$currentLayer" tunnel="yes"/>
                        </apply-templates>
                        <apply-templates mode="step_two" select="$currentIterationElement/*">
                          <with-param as="xs:integer" name="pVariantsIteration" select="$currentLayer" tunnel="yes"/>
                        </apply-templates>
                      </element>
                    </iterate>
                  </when>
                  <when test="$matchedElement/self::supplied">
                    <apply-templates mode="step_two" select="$matchedElement/*">
                      <with-param as="xs:integer" name="pVariantsIteration" select="$currentLayer" tunnel="yes"/>
                    </apply-templates>
                  </when>
                </choose>
              </element>
            </iterate>
          </otherwise>
        </choose>
      </when>
      <when test="$REQUESTED_PARTS//dme:part[@staff = $staffN]">
        <copy>
          <apply-templates mode="#current" select="@*, node()"/>
        </copy>
      </when>

      <otherwise/>
    </choose>

  </template>

</stylesheet>
