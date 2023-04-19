<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ddi="ddi:instance:3_2" xmlns:l="ddi:logicalproduct:3_2"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- Identity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Exclude fragments containing a child with a given local name -->
    <xsl:template match="ddi:Fragment[l:Category]"/>
    
</xsl:stylesheet>