<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>
    <!-- l:RepresentedVariable or l:VariableRepresentation: How to pass a variable in XPATH expression? -->
    <xsl:variable name="representation" select="'l:RepresentedVariable'"></xsl:variable>

    <xsl:template match="/">
        <!-- Browse each logicalRecord for defining one datapoint ruleset per LogicalRecord -->
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:variable name="dataset" select="l:LogicalRecordName/r:String"/>
            <xsl:value-of select="concat($dataset, ' := input_table;')"/>
            <!-- Define datapoint ruleset with a signature including all variables in the LogicalRecord. The rule signature should be changed if each variable does not produce one rule
             -->
            <xsl:value-of
                select="concat('&#xA;define datapoint ruleset dpr_', $dataset, ' (variable ', string-join(l:VariablesInRecord/l:Variable/l:VariableName/r:String, ', '), ') is')"/>
            <!-- Apply template for defining one rule per variable in the LogicalRecord -->
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

    <!-- Template for Variable wiht VariableName as param. One different template called per type of representation  -->
    <xsl:template match="l:Variable">
        <xsl:variable name="expression" as="node()*">
            <xsl:evaluate xpath="concat($representation, '/r:CodeRepresentation',' | ', $representation, '/r:DateTimeRepresentation/r:DateTypeCode', ' | ', $representation, '/r:TextRepresentation', ' | ', $representation, '/r:NumericRepresentation/r:NumericTypeCode')" context-item="."/>
        </xsl:variable>       
           <xsl:apply-templates select="$expression">
            <xsl:with-param name="variableName" select="l:VariableName/r:String"/>
        </xsl:apply-templates>
        <!-- Last rule does not finished with a semicolon. This pattern does not work if one variable does not generate one rule (i.e: representation integer without min or max)  -->
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
        <!-- Shoud be improved because variable created even if regExp is not filled -->
        <xsl:variable name="matchCharacters" select="concat('match_characters(', $variableName, ', &quot;', @regExp, '&quot;)')"/>
        <!-- Create one vtl rule (between) if min and max lengths filled -->
        <xsl:if test="@minLength and @maxLength">
            <xsl:value-of
                select="concat('&#xA;between(length(', $variableName, '),', @minLength, ',', @maxLength, ')')"/>
            <xsl:if test="@regExp">
                <xsl:value-of
                    select="concat(' and ', $matchCharacters)"
                />
            </xsl:if>
        </xsl:if>
        <!-- Create one rule if regExp filled -->
        <xsl:if test="not(@minLength or @maxLength) and @regExp">
            <xsl:value-of select="concat('&#xA;', $matchCharacters)"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Integer']">
        <xsl:param name="variableName"/>
        <xsl:value-of
            select="concat('&#xA;between(cast(', $variableName, ', integer), ', //r:NumberRange/r:Low, ', ', //r:NumberRange/r:High, ')')"
        />
    </xsl:template>
    
    <xsl:template match="r:NumericTypeCode[text() = 'Double']">
        <xsl:param name="variableName"/>
        <xsl:value-of
            select="concat('&#xA;between(cast(', $variableName, ', number), ', //r:NumberRange/r:Low, ', ', //r:NumberRange/r:High, ')')"
        />
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Year']"> </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Date']">
        <xsl:param name="variableName"/>
        <xsl:value-of
            select="concat('&#xA;match_characters(', $variableName, ', &quot;', '^\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])$', '&quot;)')"
        />
    </xsl:template>

</xsl:stylesheet>
