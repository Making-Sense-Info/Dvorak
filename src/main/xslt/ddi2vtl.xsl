<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:variable name="dataset" select="l:LogicalRecordName/r:String"/>
            <xsl:value-of select="concat($dataset, ' := input_table;')"/>
            <xsl:value-of select="concat('define datapoint ruleset dpr_', $dataset, ' (variable ', string-join(l:VariablesInRecord/l:Variable/l:VariableName/r:String, ', '), ') is')"/>
            <xsl:apply-templates select=".">
           </xsl:apply-templates>
            <xsl:value-of select="concat('ds_eval_', $dataset, ' := check_datapoint(', $dataset,', dpr_', $dataset, ');')"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="l:LogicalRecord">
        <xsl:apply-templates select="l:VariablesInRecord/l:Variable">
        </xsl:apply-templates>
        <xsl:value-of>end datapoint ruleset;</xsl:value-of>
    </xsl:template>

    <xsl:template match="l:Variable">
        <xsl:apply-templates
            select="l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode">
            <xsl:with-param name="variableName" select="l:VariableName/r:String"></xsl:with-param>
        </xsl:apply-templates>        
    </xsl:template>

    <xsl:template match="r:CodeRepresentation">
        <xsl:param name="variableName"></xsl:param>
        <xsl:value-of select="concat($variableName, ' in {&quot;', string-join(.//l:Code/r:Value, '&quot;,&quot;'),'&quot;};')"/>
    </xsl:template>

    <xsl:template match="r:TextRepresentation">
        <xsl:param name="variableName"></xsl:param>
        <xsl:choose>
            <xsl:when test="@minLength and @maxLength">
                <xsl:value-of select="concat('between(length(', $variableName, '),', @minLength,',', @maxLength,');')"/>
            </xsl:when>
            <xsl:otherwise>//So what? </xsl:otherwise> 
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="@regExp"> 
                <xsl:value-of select="concat('match_characters(', $variableName, ', &quot;',@regExp, '&quot;);')"/>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Integer']">
        <xsl:param name="variableName"></xsl:param>
        <xsl:value-of select="concat('between(cast(', $variableName, ', number), ', //r:NumberRange/r:Low,', ', //r:NumberRange/r:High, ');')"/>
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Year']">
        </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Date']"> 
// DateTimeRepresentation: Date
    </xsl:template>

</xsl:stylesheet>
