<?xml version="1.0" encoding="UTF-8"?>
<stylesheet exclude-result-prefixes="xs xd dme functx dita mei map array" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:dita="http://dita-ot.sourceforge.net" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:functx="http://www.functx.com" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.music-encoding.org/ns/mei">


  <xd:doc>
    <xd:desc>Given two absolute paths, this function calculates the relative path from path1 to path2.</xd:desc>
    <xd:param name="path1">Absolute path from which the relative path is calculated.</xd:param>
    <xd:param name="path2">Absolute path to which the relative path is calculated.</xd:param>
    <xd:param name="delimiter">Use '\\' for Windows or '/' for Linux as usual.</xd:param>
  </xd:doc>
  <function as="xs:string" name="dme:relative-path">
    <param as="xs:string" name="path1"/>
    <param as="xs:string" name="path2"/>
    <param as="xs:string" name="delimiter"/>

    <!-- Convert paths to seuences -->
    <variable name="segments1" select="tokenize($path1, $delimiter)"/>
    <variable name="segments2" select="tokenize($path2, $delimiter)"/>

    <!-- Find the common base index -->
    <variable as="xs:integer" name="commonBaseIndex">
      <sequence select="
          max(
          for $i in 1 to min((count($segments1), count($segments2)))
          return
            if ($segments1[$i] = $segments2[$i]) then
              $i
            else
              ()
          )"/>
    </variable>

    <!-- Calculate the relative path -->
    <variable name="upSteps" select="count($segments1) - $commonBaseIndex - 1"/>
    <variable name="downSteps" select="subsequence($segments2, $commonBaseIndex + 1, count($segments2) - $commonBaseIndex)"/>

    <!-- Construct the relative path -->
    <variable as="xs:string+" name="relativePath">
      <for-each select="1 to $upSteps">
        <sequence select="'..' || $delimiter"/>
      </for-each>
      <for-each select="subsequence($downSteps, 1, count($downSteps) - 1)">
        <sequence select="concat(., $delimiter)"/>
      </for-each>
    </variable>

    <sequence select="string-join($relativePath, '')"/>
  </function>


  <xd:doc>
    <xd:desc>Extension of the functx:add-attributes <xd:p> Original description: <!--
  Adds attributes to XML elements 

 @author  Priscilla Walmsley, Datypic 
 @version 1.0 
 @see     http://www.xsltfunctions.com/xsl/functx_add-attributes.html 
 @param   $elements the element(s) to which you wish to add the attribute 
 @param   $attrNames the name(s) of the attribute(s) to add 
 @param   $attrValues the value(s) of the attribute(s) to add 
-->
      </xd:p>
      <xd:p>Do not add namespace when constructing the attribute as it causes the addtion of namespace prefix to the attribute and additional namespace declaration on the element.</xd:p>
    </xd:desc>
    <xd:param name="elements">$elements the element(s) to which you wish to add the attribute </xd:param>
    <xd:param name="attrNames">$attrNames the name(s) of the attribute(s) to add</xd:param>
    <xd:param name="attrValues">$attrValues the value(s) of the attribute(s) to add </xd:param>
  </xd:doc>
  <function as="element()?" name="dme:add-mei-attributes" xmlns:dme="http://www.mozarteum.at/ns/dme">
    <param as="element()*" name="elements"/>
    <param as="xs:QName*" name="attrNames"/>
    <param as="xs:anyAtomicType*" name="attrValues"/>

    <for-each select="$elements">
      <variable name="element" select="."/>
      <copy>
        <for-each select="$attrNames">
          <variable name="seq" select="position()"/>
          <!-- Exclude xmlns:ns0 namespace declaration -->
          <choose>
            <when test="namespace-uri-from-QName(.) != 'http://www.w3.org/1999/XSL/Transform'">
              <attribute name="{.}" namespace="{namespace-uri-from-QName(.)}" select="$attrValues[$seq]"/>
            </when>
            <otherwise>
              <attribute name="{.}" select="$attrValues[$seq]"/>
            </otherwise>
          </choose>
        </for-each>
        <copy-of select="@*[not(node-name(.) = $attrNames)] | node()"/>
      </copy>
    </for-each>

  </function>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 22, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b>Oleksii Sapov</xd:p>
      <xd:p>DIME functions library</xd:p>
    </xd:desc>
  </xd:doc>
  <function as="xs:string*" name="dme:tokenize-normalize-attr-vals">
    <param name="attr"/>
    <param name="pattern"/>

    <variable name="tok" select="
        for $a in $attr
        return
          tokenize($a, $pattern)"/>

    <sequence select="
        for $a in $tok
        return
          normalize-space($a)"/>
  </function>

  <function as="xs:string*" name="dme:tok-vals-with-space">
    <param name="attr"/>

    <variable name="tok" select="
        for $a in $attr
        return
          tokenize($a, '\s')"/>

    <sequence select="
        for $a in $tok
        return
          normalize-space($a)"/>
  </function>

  <xd:doc>
    <xd:desc>Outputs a sequence of strings.</xd:desc>
    <xd:param name="arg1">Input element which contains the string.</xd:param>
    <xd:param name="arg2">ID of the input field (DIME-tools, optional)</xd:param>
  </xd:doc>
  <xsl:function name="dme:tokValues">
    <xsl:param as="element()" name="arg1"/>
    <xsl:param as="xs:string" name="arg2"/>

    <xsl:variable name="textNode " select="$arg1/id($arg2)/string(text())"/>

    <xsl:sequence select="
        for $n in tokenize($textNode, ',')
        return
          normalize-space($n)"/>

  </xsl:function>

</stylesheet>
