<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="l:LogicalRecord">
        <xsl:apply-templates select="l:VariablesInRecord/l:Variable">
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="l:Variable">
        <xsl:param name="dataset" select="ancestor::l:LogicalRecord/l:LogicalRecordName/r:String"></xsl:param>
        <xsl:param name="variableName" select="l:VariableName/r:String"></xsl:param>
        <xsl:apply-templates
            select="l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode">
            <xsl:with-param name="dataset" select="$dataset"></xsl:with-param>
            <xsl:with-param name="variableName" select="$variableName"></xsl:with-param>
        </xsl:apply-templates>        
    </xsl:template>

    <xsl:template match="r:CodeRepresentation">
        <xsl:param name="dataset"></xsl:param>
        <xsl:param name="variableName"></xsl:param>
I'm a CodeRepresentation
ds_r := <xsl:value-of select="$dataset"/>#<xsl:value-of select="$variableName"/> in 
        {"<xsl:value-of select="string-join(.//l:Code/r:Value, '&quot;,&quot;')"/>"}; 
    </xsl:template>

    <xsl:template match="r:TextRepresentation">
        <xsl:param name="dataset"></xsl:param>
        <xsl:param name="variableName"></xsl:param>
TextRepresentation
        <xsl:choose>
            <xsl:when test="@minLength and @maxLength">
ds_r := check(between(length(<xsl:value-of select="$dataset"
                />#<xsl:value-of select="$variableName"/>), <xsl:value-of
                    select="@minLength"/>, <xsl:value-of select="@maxLength"/>));
            </xsl:when>
            <xsl:otherwise> So what? </xsl:otherwise> 
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="@regExp"> 
RegExp <xsl:value-of select="@regExp"/>;
            </xsl:when> 
        </xsl:choose>

    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Integer']">
        <xsl:param name="dataset"></xsl:param>
        <xsl:param name="variableName"></xsl:param>
NumericRepresentation
ds_r := check(between(cast(<xsl:value-of select="$dataset"/>#<xsl:value-of select="$variableName"/>, integer), <xsl:value-of
            select="//r:NumberRange/r:Low"/>, <xsl:value-of select="//r:NumberRange/r:High"/>));
    </xsl:template>
    

    <xsl:template match="r:DateTypeCode[text() = 'Year']"> 
I'm a DateTimeRepresentation,
DateTypeCode = Year </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Date']"> 
I'm a DateTimeRepresentation,
DateTypeCode = Date </xsl:template>

</xsl:stylesheet>
