<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- L'élément ddi:FragmentInstance va contenir un ou plusieurs ddi:TopLevelReference -->
    <!-- C'est le contenu de ces éléments qui nous intéressent -->
    <xsl:template match="ddi:FragmentInstance">
        <xsl:copy>
            <xsl:apply-templates select="ddi:TopLevelReference"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Par défaut, on recopie tout ce qu'on rencontre -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Pour tout élément qui correspond à une référence, on va récupérer la référence correspondante qui se trouvera dans un autre fragment DDI -->
    <xsl:template match="*[ends-with(name(),'Reference')]">
        <xsl:variable name="idReference" select="r:ID"/>
        <xsl:apply-templates select="//*[parent::ddi:Fragment and r:ID=$idReference]"/>
    </xsl:template>
    
</xsl:stylesheet>