<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">

  <variable name="ATTRIBUTES_TO_DELETE" select="('stem.dir', 'stem.sameas', 'ploc', 'oloc')"/>

  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template match="staff" mode="step_one">
    <variable as="attribute(n)" name="staffNumber" select="@n"/>
    <choose>
      <when test="$REQUESTED_PARTS//dme:part[@staff = $staffNumber]/@split">
        <call-template name="splitStaff"/>
      </when>
      <when test="
          some $staff in $REQ_PARTS_EXTRACT_LAYERS
            satisfies $staff = @n">
        <copy>
          <apply-templates select="@*"/>
          <variable as="xs:integer" name="newStaffNumber">
            <call-template name="get.new.staff.number">
              <with-param as="xs:integer" name="staffN" select="xs:integer(@n)"/>
            </call-template>
          </variable>
          <attribute name="n" select="$newStaffNumber"/>
          <!--Special case for K. 550-->
          <if test="app">
            <call-template name="process.app">
              <with-param name="staffN" select="@n"/>
            </call-template>
          </if>
          <apply-templates mode="layer" select="layer[@n = $REQUESTED_PARTS//dme:part[@staff = current()/@n]/@layer]"/>
        </copy>
      </when>
      <when test="
          some $staff in $REQ_PARTS_EXTRACT_STAVES
            satisfies $staff = @n">
        <copy>
          <apply-templates select="@*"/>
          <variable as="xs:integer" name="newStaffNumber">
            <call-template name="get.new.staff.number">
              <with-param as="xs:integer" name="staffN" select="xs:integer(@n)"/>
            </call-template>
          </variable>
          <attribute name="n" select="$newStaffNumber"/>
          <apply-templates select="node()"/>
        </copy>
      </when>
    </choose>
  </template>



  <xd:doc>
    <xd:desc/>
    <xd:param name="staffN"/>
  </xd:doc>
  <template name="process.app">
    <param name="staffN"/>

    <variable name="IDsecondPart" select="substring-after(@xml:id, '_')"/>
    <app xmlns="http://www.music-encoding.org/ns/mei">
      <!--<xsl:attribute name="xml:id" select="'app_' || $IDsecondPart"/>-->
      <xsl:apply-templates select="app/@*"/>
      <xsl:variable name="currApp" select="app"/>

      <!--If app would have more variants-->
      <xsl:for-each select="1 to count($currApp/child::*)">
        <xsl:variable name="counter" select=". cast as xs:integer"/>
        <xsl:variable name="child" select="($currApp/child::*)[$counter]"/>
        <xsl:element name="{$child/name()}">
          <xsl:apply-templates select="$child/@*"/>
          <xsl:variable as="xs:string" name="reqLayer" select="dme:requested-layer($staffN)"/>
          <xsl:apply-templates mode="layer" select="$child/layer[@n = $reqLayer]"/>
        </xsl:element>
      </xsl:for-each>
    </app>

  </template>




  <xd:doc>
    <xd:desc>
      <xd:p>Resolves layer[@sameas] or processes the descendants of the layer.</xd:p>
    </xd:desc>
  </xd:doc>
  <template match="layer" mode="layer">
    <choose>
      <when test="@sameas">

        <variable as="element(layer)" name="pointedLayer">
          <call-template name="get.sameas.element"/>
        </variable>

        <!--Replace ID with the current.-->
        <copy-of select="functx:add-or-update-attributes($pointedLayer, xs:QName('xml:id'), @xml:id)"/>
      </when>
      <when test="descendant::node()">
        <copy>
          <call-template name="create.first.layer"/>
          <call-template name="layer.descendants">
            <with-param name="pElements" select="node()"/>
          </call-template>
        </copy>
      </when>
    </choose>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Returns element which is pointed by @sameas.</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="get.sameas.element">
    <try>
      <sequence select="substring-after(@sameas, '#') => id()"/>
      <catch>
        <message>The referenced @sameas-element does not exist! Current element ID: <value-of select="@xml:id"/></message>
      </catch>
    </try>
    <if test="not(substring-after(@sameas, '#') => id() instance of element())">
      <message>The referenced @sameas-element does not exist! Current element ID: <value-of select="@xml:id"/></message>
    </if>
  </template>

  <xd:doc>
    <xd:desc>
      <xd:p>Resolves @sameas. Original attributes from the 'pointed node' are preserved. Attributes defined in $ATTRIBUTES_TO_DELETE are deleted. Recursive template.</xd:p>
    </xd:desc>
    <xd:param name="pElements">Descendant nodes of the mei:layer.</xd:param>
  </xd:doc>
  <template name="layer.descendants">
    <param name="pElements"/>

    <for-each select="$pElements">
      <choose>
        <when test="@sameas and not(node())">
          <variable as="element()" name="resolvedElement">
            <call-template name="resolve.sameas.element"/>
          </variable>
          <copy-of select="functx:remove-attributes($resolvedElement, $ATTRIBUTES_TO_DELETE)"/>
        </when>
        <!--Assumes node().-->
        <when test="@sameas">
          <copy>
            <variable as="element()" name="pointedElement">
              <call-template name="get.sameas.element"/>
            </variable>

            <variable name="currentAttributes" select="@* except @sameas"/>
            <variable name="pointedElementAttributes" select="$pointedElement/@*[not(local-name() = ($ATTRIBUTES_TO_DELETE, $currentAttributes/local-name()))]"/>
            <copy-of select="$currentAttributes"/>
            <copy-of select="$pointedElementAttributes"/>
            <call-template name="layer.descendants">
              <with-param name="pElements" select="node()"/>
            </call-template>
          </copy>
        </when>
        <when test="node()">
          <copy>
            <apply-templates select="@*[not(local-name() = $ATTRIBUTES_TO_DELETE)]"/>
            <call-template name="layer.descendants">
              <with-param name="pElements" select="node()"/>
            </call-template>
          </copy>
        </when>
        <!--Do not process text nodes.-->
        <when test=". instance of element()">
          <choose>
            <!--Replace mSpace with mRest-->
            <when test="(local-name() = 'mSpace') and (@type = 'rest')">
              <mRest xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                  <xsl:choose>
                    <xsl:when test="contains(@xml:id, '_')">
                      <xsl:sequence select="'mrest_' || substring-after(@xml:id, '_')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:copy select="@xml:id"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates mode="#current" select="@* except (@type, @xml:id)"/>
              </mRest>
            </when>
            <!--Replace space with rest-->
            <when test="(local-name() = 'space') and (@type = 'rest')">
              <rest xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                  <xsl:choose>
                    <xsl:when test="contains(@xml:id, '_')">
                      <xsl:sequence select="'rest_' || substring-after(@xml:id, '_')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:copy select="@xml:id"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates mode="#current" select="@* except (@type, @xml:id)"/>
              </rest>
            </when>
            <otherwise>
              <copy-of select="functx:remove-attributes(., $ATTRIBUTES_TO_DELETE)"/>
            </otherwise>
          </choose>
        </when>
        <otherwise>
          <copy-of select="."/>
        </otherwise>
      </choose>
    </for-each>
  </template>


  <xd:doc>
    <xd:desc>
      <xd:p>Returns referenced element. Replaces the attribute values or adds the attributes from the pointer element.</xd:p>
    </xd:desc>
  </xd:doc>
  <template name="resolve.sameas.element">

    <variable as="element()" name="pointedElement">
      <call-template name="get.sameas.element"/>
    </variable>


    <!--Attributes which will be preserved-->
    <variable name="attrs" select="@*[local-name() != 'sameas']"/>

    <variable as="xs:QName*" name="attrsQNames">
      <for-each select="$attrs">
        <sequence select="xs:QName(name())"/>
      </for-each>
    </variable>
    <variable as="xs:string*" name="vals">
      <for-each select="$attrs">
        <sequence select="string()"/>
      </for-each>
    </variable>
    <copy-of select="dme:add-mei-attributes($pointedElement, $attrsQNames, $vals)"/>
  </template>


  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template name="create.first.layer">
    <attribute name="n" select="'1'"/>
    <attribute name="xml:id" select="@xml:id"/>
    <apply-templates select="@* except (@n, @xml:id)"/>
  </template>



  <xd:doc>
    <xd:desc/>
    <xd:param name="pDocNode"/>
  </xd:doc>
  <template name="calculate.multirest.measures">
    <param name="pDocNode"/>

    <variable as="element()*" name="firstMeasureMrest" select="
        $pDocNode//measure[descendant::mRest and
        not((preceding-sibling::measure)[last()][descendant::mRest])]"/>


    <iterate select="$firstMeasureMrest">
      <param as="xs:integer" name="pCounter" select="1"/>
      <param name="pMeasuresToDelete" select="[]"/>
      <param name="pMeasuresToConvert" select="map {}"/>

      <on-completion>
        <config xmlns="http://www.mozarteum.at/ns/dme">
          <measuresToDelete>
            <xsl:value-of select="$pMeasuresToDelete"/>
          </measuresToDelete>
          <xsl:for-each select="map:keys($pMeasuresToConvert)">
            <measuresToConvert count="{map:get($pMeasuresToConvert, current())}" id="{.}"/>
          </xsl:for-each>

        </config>
      </on-completion>

      <variable as="element(dme:measure)" name="mrestsCount">
        <call-template name="mrests.count"/>
      </variable>


      <choose>
        <when test="$mrestsCount/@count > 4">
          <next-iteration>
            <with-param name="pCounter" select="$pCounter + 1"/>
            <with-param name="pMeasuresToDelete" select="array:append($pMeasuresToDelete, $mrestsCount/@ids)"/>
            <with-param name="pMeasuresToConvert" select="map:put($pMeasuresToConvert, @xml:id, $mrestsCount/@count)"/>
          </next-iteration>
        </when>
        <otherwise>
          <next-iteration>
            <with-param name="pCounter" select="$pCounter + 1"/>
            <with-param name="pMeasuresToDelete" select="$pMeasuresToDelete"/>
            <with-param name="pMeasuresToConvert" select="$pMeasuresToConvert"/>
          </next-iteration>
        </otherwise>
      </choose>
    </iterate>
  </template>


  <xd:doc>
    <xd:desc/>
  </xd:doc>
  <template name="mrests.count">
    <iterate select="following-sibling::measure">
      <param as="xs:integer" name="pCounter" select="1"/>
      <param name="pMeasureIds" select="[]"/>

      <on-completion>
        <measure count="{$pCounter}" ids="{$pMeasureIds}" xmlns="http://www.mozarteum.at/ns/dme"/>
      </on-completion>
      <choose>
        <when test="descendant::mRest">
          <variable as="xs:integer" name="newCounter" select="$pCounter + 1"/>
          <next-iteration>
            <with-param name="pCounter" select="$newCounter"/>
            <with-param name="pMeasureIds" select="array:append($pMeasureIds, @xml:id)"/>
          </next-iteration>
        </when>
        <otherwise>
          <sequence>
            <measure count="{$pCounter}" ids="{$pMeasureIds}" xmlns="http://www.mozarteum.at/ns/dme"/>
          </sequence>
          <break/>
        </otherwise>
      </choose>
    </iterate>
  </template>


  <xd:doc>
    <xd:desc/>
    <xd:param name="pMultiRestMeasures"/>
  </xd:doc>
  <template match="measure[.//mRest and $SHRINK_MEASURES]" mode="step_two">
    <param as="element()?" name="pMultiRestMeasures" tunnel="yes"/>

    <variable as="attribute()" name="measureId" select="@xml:id"/>
    <variable as="element()?" name="itemMeasureToConvert" select="$pMultiRestMeasures//dme:measuresToConvert[@id = $measureId]"/>

    <choose>
      <when test="($pMultiRestMeasures//dme:measuresToDelete => tokenize()) = @xml:id"/>
      <when test="$itemMeasureToConvert">
        <copy>
          <variable as="xs:integer" name="lastMeasureN" select="xs:integer($itemMeasureToConvert/@count) + xs:integer(@n) - 1"/>
          <variable as="xs:string" name="newMeasuresRange" select="
              @n || '-' ||
              xs:string($lastMeasureN)"/>
          <attribute name="n" select="$newMeasuresRange"/>
          <attribute name="xml:id">
            <choose>
              <when test="contains(@xml:id, '_')">
                <sequence select="'mm' || $newMeasuresRange || '_' || substring-after(@xml:id, '_')"/>
              </when>
              <otherwise>
                <sequence select="@xml:id"/>
              </otherwise>
            </choose>
          </attribute>
          <apply-templates mode="#current" select="@* except (@xml:id, @n), node()"/>
        </copy>
      </when>
      <otherwise>
        <copy>
          <apply-templates select="@*, node()"/>
        </copy>
      </otherwise>
    </choose>
  </template>



  <xd:doc>
    <xd:desc/>
    <xd:param name="pMultiRestMeasures"/>
  </xd:doc>
  <template match="mRest" mode="step_two">
    <param as="element()?" name="pMultiRestMeasures" tunnel="yes"/>

    <variable as="attribute()" name="ancestorMeasureId" select="ancestor::measure/@xml:id"/>
    <variable as="element()?" name="itemMeasureToConvert" select="$pMultiRestMeasures//dme:measuresToConvert[@id = $ancestorMeasureId]"/>

    <choose>
      <when test="$itemMeasureToConvert">
        <element name="multiRest" namespace="http://www.music-encoding.org/ns/mei">
          <apply-templates select="@*"/>
          <attribute name="num" select="
              $itemMeasureToConvert/@count"/>
        </element>
      </when>
      <otherwise>
        <copy-of select="."/>
      </otherwise>
    </choose>

  </template>


  <xd:doc>
    <xd:desc>When the staff is split, several staves are created, depending on the number of layers.</xd:desc>
  </xd:doc>
  <template name="splitStaff">
    <variable as="element(staff)" name="currentStaff" select="."/>
    <iterate select="layer">

      <variable as="xs:integer" name="newStaffNumber">
        <call-template name="get.new.staff.number">
          <with-param as="xs:integer" name="staffN" select="xs:integer($currentStaff/@n)"/>
          <with-param as="xs:integer" name="layerN" select="xs:integer(@n)"/>
        </call-template>
      </variable>

      <element name="staff" namespace="http://www.music-encoding.org/ns/mei">
        <apply-templates select="$currentStaff/@* except (@xml:id, @n)"/>
        <attribute name="n" select="$newStaffNumber"/>
        <attribute name="xml:id" select="$currentStaff/@xml:id || '_' || $newStaffNumber"/>

        <variable name="extractedLayer">
          <apply-templates mode="layer" select="."/>
        </variable>

        <!--  <variable name="adjustedLayerIds">
          <apply-templates mode="adjustLayerIds" select="$extractedLayer">
            <with-param as="xs:string" name="currentLayerN" select="@n" tunnel="yes"/>
          </apply-templates>
        </variable>-->

        <copy-of select="$extractedLayer"/>

      </element>
    </iterate>
  </template>


</stylesheet>
