<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>
    <!-- l:RepresentedVariable or l:VariableRepresentation: How to pass a variable in XPATH expression? -->
    <!-- <xsl:variable name="representation">l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode</xsl:variable> -->
    <xsl:variable name="representation" select="'l:RepresentedVariable'"/>
    <xsl:template match="/">
        <!-- Browse each logicalRecord for defining one datapoint ruleset per LogicalRecord -->
        <xsl:for-each select="//l:LogicalRecord">
            <xsl:variable name="dataset" select="l:LogicalRecordName/r:String"/>
            <xsl:value-of select="concat('&#xA;', $dataset, ' := input_table;')"/>
            <!-- Define datapoint ruleset with a signature including all variables in the LogicalRecord. The rule signature should be changed if each variable does not produce one rule
             -->
            <xsl:value-of
                select="concat('&#xA;define datapoint ruleset dpr_', $dataset, ' (variable ', string-join(l:VariablesInRecord/l:Variable/l:VariableName/r:String, ', '), ') is')"/>
            <!-- Apply template for defining one rule per variable in the LogicalRecord -->
            <xsl:apply-templates select="."> </xsl:apply-templates>
            <xsl:value-of
                select="concat('&#xA;ds_', $dataset, '_validation_all', ' := check_datapoint(', $dataset, ', dpr_', $dataset, ' all);')"/>
            <xsl:value-of
                select="concat('&#xA;ds_', $dataset, '_validation_invalid', ' := check_datapoint(', $dataset, ', dpr_', $dataset, ' invalid);')"
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
            <xsl:evaluate
                xpath="concat($representation, '/r:CodeRepresentation', ' | ', $representation, '/r:DateTimeRepresentation/r:DateTypeCode', ' | ', $representation, '/r:TextRepresentation', ' | ', $representation, '/r:NumericRepresentation/r:NumericTypeCode')"
                context-item="."/>
        </xsl:variable>
        <xsl:variable name="semicolon">
            <xsl:if test="position() != last()">
                <xsl:value-of select="';'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:apply-templates select="$expression">
            <xsl:with-param name="variableName" select="l:VariableName/r:String"/>
            <xsl:with-param name="semicolon" select="$semicolon"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="r:CodeRepresentation">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:choose>
            <xsl:when test=".//l:Code/r:Value">
                <xsl:value-of
                    select="concat('&#xA;', 'rule_', $variableName, ' : ', $variableName, ' in {&quot;', string-join(.//l:Code/r:Value, '&quot;,&quot;'), '&quot;}', ' errorcode &quot;Code value not valid&quot;', $semicolon)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('&#xA;', '// ', 'Incomplete metadata for variable: ', $variableName)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="r:TextRepresentation">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <!-- Shoud be improved because variable created even if regExp is not filled -->
        <xsl:variable name="matchCharacters">
            <xsl:if test="@regExp">
                <xsl:value-of
                    select="concat('match_characters(', $variableName, ', &quot;', @regExp, '&quot;)')"
                />
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <!-- Create one vtl rule (between) if min and max lengths filled -->
            <xsl:when test="@minLength and @maxLength and not(@regExp)">
                <xsl:value-of
                    select="concat('&#xA;', 'rule_', $variableName, ' : ', 'between(length(', $variableName, '), ', @minLength, ', ', @maxLength, ')', ' errorcode &quot;Value not included between min and max&quot;', $semicolon)"
                />
            </xsl:when>
            <xsl:when test="@minLength and @maxLength and @regExp">
                <xsl:value-of
                    select="concat('&#xA;', 'rule_', $variableName, ' : ', 'between(length(', $variableName, '), ', @minLength, ', ', @maxLength, ')', ' and ', $matchCharacters, ' errorcode &quot;Value not included between min and max or not matched with regular expression&quot;', $semicolon)"
                />
            </xsl:when>
            <!-- Create one rule if regExp filled -->
            <xsl:when test="not(@minLength or @maxLength) and @regExp">
                <xsl:value-of
                    select="concat('&#xA;', 'rule_', $variableName, ' : ', $matchCharacters, ' errorcode &quot;Value not matched with regular expression&quot;', $semicolon)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('&#xA;', '// ', 'Incomplete metadata for variable: ', $variableName)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Integer']">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:choose>
            <xsl:when test=".//r:NumberRange/r:Low and .//r:NumberRange/r:High">
                <xsl:value-of
                    select="concat('&#xA;', 'rule_', $variableName, ' : ', 'between(cast(', $variableName, ', number), ', .//r:NumberRange/r:Low, ', ', .//r:NumberRange/r:High, ')', ' errorcode &quot;Value not included between min and max&quot;', $semicolon)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('&#xA;', '// ', 'Incomplete metadata for variable: ', $variableName)"
                />
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <xsl:template match="r:NumericTypeCode[text() = 'Double']">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:value-of
            select="concat('&#xA;', 'rule_', $variableName, ' : ', 'between(cast(', $variableName, ', number), ', //r:NumberRange/r:Low, ', ', //r:NumberRange/r:High, ')', ' errorcode &quot;Value not included between min and max&quot;', $semicolon)"
        />
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Year']">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:value-of
            select="concat('&#xA;', 'rule_', $variableName, ' : ', 'match_characters(', $variableName, ', &quot;', '^\d{4}$', '&quot;)', ' errorcode &quot;Date format YYYY not valid&quot;', $semicolon)"
        />
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'YearMonth']">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:value-of
            select="concat('&#xA;', 'rule_', $variableName, ' : ', 'match_characters(', $variableName, ', &quot;', '^\d{4}-(((0)[0-9])|((1)[0-2]))$', '&quot;)', ' errorcode &quot;Date format YYYY-MM-DD not valid&quot;', $semicolon)"
        />
    </xsl:template>

    <xsl:template match="r:DateTypeCode[text() = 'Date']">
        <xsl:param name="variableName"/>
        <xsl:param name="semicolon"/>
        <xsl:value-of
            select="concat('&#xA;', 'rule_', $variableName, ' : ', 'match_characters(', $variableName, ', &quot;', '^\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])$', '&quot;)', ' errorcode &quot;Date format YYYY-MM-DD not valid&quot;', $semicolon)"
        />
    </xsl:template>

</xsl:stylesheet>
