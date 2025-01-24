<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="#all" version="4.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">
  <doc scope="stylesheet" xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>
        <i>Inserts missing layer@sameas for staves which contain parts that share a staff.</i>
      </p>
      <p/>
      <pre> </pre>
      <p>
        <b>Created on: </b>Sep, 4 2018<ul>
          <li>
            <i>Versions</i>: <ul>
              <li>04.09.2018: <i>1.0.0</i></li>
              <li>01.04.2019: <i>2.0.0</i></li>
              <li>17.04.2019: <i>2.1.0</i></li>
              <li id="version">01.10.2019: <i>2.1.1</i></li>
              <li>2024-11-19: <i>3.0.0</i>: dme/dime/tools/extract-parts#106</li>
            </ul>
          </li>
        </ul>
      </p>
      <p><b>Contributors</b>: Oleksii Sapov-Erlinger.<pre/><b>Copyright</b>: 2020-2025 Internationale Stiftung Mozarteum Salzburg.<pre/>Licensed under the Educational Community License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at <a href="https://opensource.org/licenses/ECL-2.0">https://opensource.org/licenses/ECL-2.0</a><pre/>Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.</p>
    </desc>
  </doc>



  <include href="../../lib/basic.xsl"/>

  <variable as="element(mei:scoreDef)" name="SCORE_DEF" select="//scoreDef[not(preceding::scoreDef)]"/>

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

  <template match="staff">

    <!--<message>
      <value-of select="@xml:id"/>
    </message>-->
    <choose>
      <when test="map:get($PARTS_THAT_SHARE_A_STAFF, xs:integer(@n))">
        <variable as="attribute(n)" name="staffN" select="@n"/>
        <variable as="element(staffDef)" name="staffDeclaration" select="$SCORE_DEF//staffDef[@n = $staffN]"/>
        <variable as="xs:integer+" name="declaredNumberOfLayers" select="$staffDeclaration//layerDef => count()"/>
        <variable as="xs:integer" name="currentNuberOflayers" select=".//layer => count()"/>

        <choose>
          <when test="$currentNuberOflayers &lt; $declaredNumberOfLayers">
            <copy>
              <!--            <variable as="xs:integer" name="numberOfMissingLayers" select="$declaredNumberOfLayers - $currentNuberOflayers"/>-->
              <apply-templates select="@*"/>
              <apply-templates select="layer"/>

              <variable as="attribute(n)+" name="declaredNumberOfLayers" select="$staffDeclaration//layerDef/@n"/>

              <variable as="attribute(n)+" name="currentLayerNumbers" select="./layer/@n"/>
              <variable as="attribute(n)*" name="missingLayers" select="$staffDeclaration//layerDef[not(@n = $currentLayerNumbers)]/@n"/>

              <variable as="xs:string" name="pointerValue" select="'#' || layer[@n = 1]/@xml:id"/>
              <variable as="element(layer)" name="layer" select="layer"/>

              <iterate select="$missingLayers">
                <element name="layer" namespace="http://www.music-encoding.org/ns/mei">
                  <attribute name="xml:id" select="$layer/@xml:id || '_' || ."/>
                  <attribute name="n" select="."/>
                  <attribute name="sameas" select="$pointerValue"/>
                </element>
              </iterate>

            </copy>
          </when>
          <otherwise>
            <copy-of select="."/>
          </otherwise>
        </choose>
      </when>
      <otherwise>
        <copy-of select="."/>
      </otherwise>
    </choose>

  </template>

</stylesheet>
