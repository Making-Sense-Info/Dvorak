<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:variable name="LogicalRecordName"
                select="l:LogicalRecordName/r:String"
                as="xs:string"/>
I'm a LogicalRecord named: <xsl:value-of select="$LogicalRecordName"/>
            <xsl:for-each select="current()/l:VariablesInRecord/l:Variable">
                <xsl:apply-templates select="."/>
            </xsl:for-each>            
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="l:Variable">

I'm a variable named: <xsl:value-of select="l:VariableName/r:String"/>
        <xsl:apply-templates select="l:RepresentedVariable"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="l:RepresentedVariable">
        <xsl:value-of select="RepresentedVariableName"/>
        <xsl:apply-templates select="r:CodeRepresentation | r:DateTimeRepresentation/r:DateTypeCode | r:TextRepresentation | r:NumericRepresentation"/>
    </xsl:template>
    
    <xsl:template match="r:CodeRepresentation">
I'm a CodeRepresentation. Code values are: <xsl:value-of select="string-join(.//l:Code/r:Value, ', ')"/>     
    </xsl:template>
    
    <xsl:template match="r:TextRepresentation">
I'm a TextRepresentation
Minimum <xsl:value-of select="./@minLength"/>
Maximum <xsl:value-of select="./@maxLength"/>
        <xsl:choose>
            <xsl:when test="./@regExp">
RegExp <xsl:value-of select="./@regExp"/>
            </xsl:when>
            <xsl:otherwise>
So what?
            </xsl:otherwise>
        </xsl:choose>     
    </xsl:template>
    
    <xsl:template match="r:NumericRepresentation">
I'm a NumericRepresentation
Low <xsl:value-of select="./r:NumberRange/r:Low"/>
High <xsl:value-of select="./r:NumberRange/r:High"/>   
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Year']">
I'm a DateTimeRepresentation, DateTypeCode = Year
    </xsl:template>
    
    <xsl:template match="r:DateTypeCode[text() = 'Date']">
I'm a DateTimeRepresentation, DateTypeCode = Date
    </xsl:template>

</xsl:stylesheet>
