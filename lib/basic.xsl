<?xml version="1.0" encoding="UTF-8"?>
<stylesheet xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:dme="http://www.mozarteum.at/ns/dme" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <character-map name="entities">
    <output-character character="&#8198;" string="&amp;#8198;"/>
    <output-character character="&#8194;" string="&amp;#8194;"/>
    <output-character character="&#8195;" string="&amp;#8195;"/>
    <output-character character="&#8211;" string="&amp;#8211;"/>
    <output-character character="&#160;" string="&amp;#160;"/>
    <output-character character="&#xea5c;" string="&amp;#xea5c;"/>
    <output-character character="&#xe263;" string="&amp;#xe263;"/>
    <output-character character="&#xea56;" string="&amp;#xea56;"/>
    <output-character character="&#x1D10B;" string="&amp;#x1D10B;"/>
    <output-character character="&#324;" string="&amp;#324;"/>
    <!--		try RegEx to match all characters -->
    <!--<output-character character="&amp;" string="abs" />-->

    <!--		needed to replace &amp; to & -->
    <output-character character="«" string="&amp;"/>
  </character-map>

  <output standalone="no" encoding="UTF-8" indent="yes" method="xml" use-character-maps="entities"/>
  <!--saxon:indent-spaces="2" -->
  <strip-space elements="*"/>


  <template match="node() | @*" mode="#all">
    <copy>
      <apply-templates mode="#current" select="node() | @*"/>
    </copy>
  </template>

  <template name="copy.element">
    <copy>
      <apply-templates mode="#current" select="@* | node()"/>
    </copy>
  </template>

</stylesheet>
