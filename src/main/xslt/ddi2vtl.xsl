<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:variable name="dataset" select="l:LogicalRecordName/r:String"/>
            <xsl:value-of select="concat($dataset, ' := input_table;', '&#xA;')"/>
            <xsl:value-of
                select="concat('define datapoint ruleset dpr_', $dataset, ' (variable ', string-join(l:VariablesInRecord/l:Variable/l:VariableName/r:String, ', '), ') is')"/>
            <xsl:apply-templates select="."> </xsl:apply-templates>
            <xsl:value-of
                select="concat('&#xA;ds_eval_', $dataset, ' := check_datapoint(', $dataset, ', dpr_', $dataset, ');')"
            />
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="l:LogicalRecord">
        <xsl:apply-templates select="l:VariablesInRecord/l:Variable"/>
        <xsl:text>&#xA;end datapoint ruleset;</xsl:text>
    </xsl:template>

    <xsl:template match="l:Variable">
        <xsl:apply-templates
            select="l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode">
            <xsl:with-param name="variableName" select="l:VariableName/r:String"/>
        </xsl:apply-templates>
        <xsl:if test="position() != last()">
            <xsl:value-of>;</xsl:value-of>
        </xsl:if>
    </xsl:template>

    <xsl:template match="r:CodeRepresentation">
        <xsl:param name="variableName"/>
        <xsl:value-of
            select="concat('&#xA;', $variableName, ' in {&quot;', string-join(.//l:Code/r:Value, '&quot;,&quot;'), '&quot;}')"
        />
    </xsl:template>

    <xsl:template match="r:TextRepresentation">
        <xsl:param name="variableName"/>
        <xsl:if test="@minLength and @maxLength">
            <xsl:value-of
                select="concat('&#xA;between(length(', $variableName, '),', @minLength, ',', @maxLength, ')')"/>
            <xsl:if test="@regExp">
                <xsl:value-of
                    select="concat(' and match_characters(', $variableName, ', &quot;', @regExp, '&quot;)')"
                />
            </xsl:if>
        </xsl:if>
        <xsl:if test="not(@minLength or @maxLength) and @regExp">
            <xsl:value-of
                select="concat('&#xA;match_characters(', $variableName, ', &quot;', @regExp, '&quot;)')"
            />
        </xsl:if>
    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Integer']">
        <xsl:param name="variableName"/>
        <xsl:value-of
            select="concat('&#xA;between(cast(', $variableName, ', number), ', //r:NumberRange/r:Low, ', ', //r:NumberRange/r:High, ')')"
        />
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Year']"> </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Date']"> // DateTimeRepresentation: Date </xsl:template>

</xsl:stylesheet>
