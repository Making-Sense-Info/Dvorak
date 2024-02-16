<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ddi="ddi:instance:3_2"
    xmlns:r="ddi:reusable:3_2" xmlns:l="ddi:logicalproduct:3_2"
    xmlns:p="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text" indent="no" media-type="text/plain" encoding="UTF-8"/>
    <!-- l:RepresentedVariable or l:VariableRepresentation: How to pass a variable in XPATH expression? -->   
    <xsl:variable name="representation" select="'l:RepresentedVariable'"/>
    <!-- <xsl:variable name="representation">l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode</xsl:variable> -->
    <xd:doc>
        <xd:desc>
            <xd:p>root : Browse each logicalRecord for defining one datapoint ruleset per LogicalRecord</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="//l:LogicalRecord"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>default template : do nothing</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="#all"/>

    <xd:doc>
        <xd:desc>
            <xd:p>for a LogicalRecord, define the list of the rules of its variables and indicates which have no rule</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="l:LogicalRecord">
        <xsl:variable name="dataset" select="l:LogicalRecordName/r:String"/>
        <!-- Apply template for defining one rule per variable in the LogicalRecord -->
        <xsl:variable name="variables-rules-structure" as="item()">
            <VariableRules>
                <xsl:apply-templates select="l:VariablesInRecord/l:Variable" mode="variable-rule"/>
            </VariableRules>
        </xsl:variable>
        <xsl:variable name="variables-rules" as="xs:string *">
            <xsl:for-each select="$variables-rules-structure//rule">
                <xsl:variable name="rule-name">
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::rule or following-sibling::rule">
                            <!-- precision in the name when several rules for the same variable -->
                            <xsl:value-of select="concat('rule_',parent::variable/@variable-name,'_',ruletype)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('rule_',parent::variable/@variable-name)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($rule-name,' : ',constraint,' errorcode &quot;',errorcode,'&quot;')"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:if test="$variables-rules-structure//variable[not(rule)]">
            <xsl:value-of select="concat('// Variables without rules : ',string-join($variables-rules-structure//variable[not(rule)]/@variable-name,', '),'&#xA;')"/>
        </xsl:if>
        <xsl:value-of select="concat($dataset, ' &lt;- input_table;')"/>
        <xsl:value-of select="concat('&#xA;define datapoint ruleset dpr_', $dataset, ' (variable ', string-join($variables-rules-structure//variable[rule]/@variable-name, ', '), ') is&#xA;')"/>
        <xsl:value-of select="string-join($variables-rules,';&#xA;')"/>
        <xsl:text>&#xA;end datapoint ruleset;&#xA;</xsl:text>
        <xsl:value-of select="concat('ds_', $dataset, '_validation_all', ' &lt;- check_datapoint(', $dataset, ', dpr_', $dataset, ' all);')"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="concat('ds_', $dataset, '_validation_invalid', ' &lt;- check_datapoint(', $dataset, ', dpr_', $dataset, ' invalid);&#xA;&#xA;')"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>a variable rule only depends on its representation</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="l:Variable" mode="variable-rule">
        <xsl:variable name="variable-name" select="l:VariableName/r:String"/>
        <variable>
            <xsl:attribute name="variable-name" select="$variable-name"/>
            <xsl:apply-templates select="l:RepresentedVariable/*[ends-with(name(),'Representation')]" mode="variable-rule">
                <xsl:with-param name="variable-name" select="$variable-name"/>
            </xsl:apply-templates>
        </variable>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>for the CodeRepresentation, the rule lists the autorized values </xd:p>
        </xd:desc>
        <xd:param name="variable-name"/>
    </xd:doc>
    <xsl:template match="r:CodeRepresentation" mode="variable-rule">
        <xsl:param name="variable-name"/>
        <xsl:if test="descendant::l:Code/r:Value">
            <rule>
                <constraint>
                    <xsl:value-of select="concat($variable-name, ' in {&quot;', string-join(descendant::l:Code/r:Value, '&quot;,&quot;'), '&quot;}')"/>
                </constraint>
                <errorcode>Code value not valid</errorcode>
            </rule>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>the TextRepresentation may have 2 rules : the string length limits and a regexp</xd:p>
        </xd:desc>
        <xd:param name="variable-name"/>
    </xd:doc>
    <xsl:template match="r:TextRepresentation" mode="variable-rule">
        <xsl:param name="variable-name"/>
        <xsl:if test="@regExp">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('match_characters(', $variable-name, ', &quot;', @regExp, '&quot;)')"/>
                </constraint>
                <errorcode>Value not matched with regular expression</errorcode>
                <ruletype>regexp</ruletype>
            </rule>
        </xsl:if>
        <xsl:if test="@minLength and @maxLength">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('between(length(', $variable-name, '), ', @minLength, ', ', @maxLength, ')')"/>
                </constraint>
                <errorcode>Value out of bounds</errorcode>
                <ruletype>length</ruletype>
            </rule>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>the NumericRepresentation may have 2 rules : with its extremal values + with the number of decimals</xd:p>
        </xd:desc>
        <xd:param name="variable-name"/>
    </xd:doc>
    <xsl:template match="r:NumericRepresentation" mode="variable-rule">
        <xsl:param name="variable-name"/>
        <xsl:if test="descendant::r:NumberRange[r:Low and r:High]">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('between(cast(', $variable-name, ', integer), ', .//r:NumberRange/r:Low, ', ', .//r:NumberRange/r:High, ')')"/>
                </constraint>
                <errorcode>Value out of bounds</errorcode>
                <ruletype>range</ruletype>
            </rule>
        </xsl:if>
        <!-- something to do with decimalPosition ? Make a difference between Integer and other numbers ? -->
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>the DateTimeRepresentation matches a regexp depending on dateTypeCode</xd:p>
        </xd:desc>
        <xd:param name="variable-name"/>
    </xd:doc>
    <xsl:template match="r:DateTimeRepresentation" mode="variable-rule">
        <xsl:param name="variable-name"/>
        <xsl:if test="r:DateTypeCode = 'Year'">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('match_characters(', $variable-name, ', &quot;', '^\d{4}$', '&quot;)')"/>
                </constraint>
                <errorcode>Date format YYYY not valid</errorcode>
            </rule>
        </xsl:if>
        <xsl:if test="r:DateTypeCode = 'YearMonth'">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('match_characters(', $variable-name, ', &quot;', '^\d{4}-(((0)[0-9])|((1)[0-2]))$', '&quot;)')"/>
                </constraint>
                <errorcode>Date format YYYY-MM not valid</errorcode>
            </rule>
        </xsl:if>
        <xsl:if test="r:DateTypeCode = 'Date'">
            <rule>
                <constraint>
                    <xsl:value-of select="concat('match_characters(', $variable-name, ', &quot;', '^\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])$', '&quot;)')"/>
                </constraint>
                <errorcode>Date format YYYY-MM-DD not valid</errorcode>
            </rule>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
