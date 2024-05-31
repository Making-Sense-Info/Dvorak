# Specification of DDI to VTL transformation

The transformation for generating VTL rules to check data conformity with its documentation expressed in DDI seems to be straightforward.

## General overview

Based on DDI/XML file containing at least one [DDI LogicalRecord](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/composite-types/LogicalRecordType/) (in general it starts at upper level as a [PhysicalInstance](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/PhysicalInstance/)), VTL ruleset are generated.

- For each [DDI LogicalRecord](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/composite-types/LogicalRecordType/) (which is the description of all of the elements (variables or NCubes) related to a single case or analysis unit), one VLT datapoint ruleset is created.

  - For each representation of each [instance variable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/Variable/) (serialized inline or defined in a RepresentedVariable referenced), one or more VTL rules are defined depending on DDI representation.

Once all variables have been scanned, the VTL `datapoint ruleset` is ended before appyling the dataset ruleset (`check_datapoint`).

All variables insufficiently documented to define a rule are quoted as a comment before the ruleset.

Ruleset name and rules name are built one the basis of the LogicalRecord name and, Variable name or in some cases the rule type.

The rule set name and rule name are built on the basis of the LogicalRecord name, variable name or rule type.

Here is an example for one PysicalInstance containing one LogicalRecord corresponding to the [test metadata made available](./src/test/ddi/physicalInstance-test.xml).
```
// Variables without rules: raison_soc
ETAB <- input_table;

define datapoint ruleset dpr_ETAB (variable mois_decl, code_decl, id_mad_etab, siren) is
    rule_mois_decl : match_characters(mois_decl, "^\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])$") errorcode "Date format YYYY-MM-DD not valid";
    rule_code_decl : code_decl in {"11","14"} errorcode "Code value not valid";
    rule_id_mad_etab : between(cast(id_mad_etab, integer), 1, 999) errorcode "Value out of bounds";
     rule_siren_regexp : match_characters(siren, "[0-9]*[1-9][0-9]*") errorcode "Value not matched with regular expression";
     rule_siren_length : between(length(siren), 9, 9) errorcode "Value out of bounds"
end datapoint ruleset;

ds_ETAB_validation_all <- check_datapoint(ETAB, dpr_ETAB all);
ds_ETAB_validation_invalid <- check_datapoint(ETAB, dpr_ETAB invalid);
```

## Mapping between DDI representation and VTL rule
Name of the instance variable is used for defining rules. 

### Numeric representation

#### Integer
Here is a DDI/XML representation for Integer including range 
```xml
<r:NumericRepresentation blankIsMissingValue="false">
        <r:NumberRange>
          <r:Low isInclusive="false">1</r:Low>
          <r:High isInclusive="false">999</r:High>
        </r:NumberRange>
        <r:NumericTypeCode>Integer</r:NumericTypeCode>
</r:NumericRepresentation>
```

After casting data as integer, the idea is to check if the data value is within the range. The corresponding VTL rule is as follow where `id_mad_etab` is the name of the instance variable:

```
rule_id_mad_etab : between(cast(id_mad_etab, integer), 1, 999) errorcode "Value out of bounds";
```

### Text representation
Here is a DDI/XML text representation including range and regular expression: 
```xml
<r:TextRepresentation blankIsMissingValue="false" maxLength="9" minLength="9" regExp="[0-9]*[1-9][0-9]*"/>
```

The idea is to check if the data value is within the range and compliant with the regular expression. The corresponding two VTL rules is as follow where `siren` is the name of the instance variable:

```
rule_siren_length : between(length(siren), 9, 9) errorcode "Value out of bounds"
rule_siren_regexp : match_characters(siren, "[0-9]*[1-9][0-9]*") errorcode "Value not matched with regular expression";
```


One rule is generated if range (min or max length) or regular expression is missing.

### Date repressentation

#### Date
Here is a DDI/XML DateTime representation for Date 
```xml
<r:DateTimeRepresentation blankIsMissingValue="false">
  <r:DateTypeCode>Date</r:DateTypeCode>
</r:DateTimeRepresentation>
```

The idea is to check if the data value is compliant with the regular expression defining a date YYYY-MM-DD. The corresponding VTL rule is as follow where `mois_decl` is the name of the instance variable:

```
rule_mois_decl : match_characters(mois_decl, "^\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])$") errorcode "Date format YYYY-MM-DD not valid";
```

#### Year

#### YearMonth

### Code representation

Here is a DDI/XML code representation. CodeRepresentati refers to a list of codes, not specified here for ease of reading.

```xml
<r:CodeRepresentation blankIsMissingValue="false">
  <r:CodeListReference>
    <r:Agency>fr.insee</r:Agency>
    <r:ID>4283cb7f-7df8-4a4c-90ec-eb507f468ef2</r:ID>
    <r:Version>1</r:Version>
    <r:TypeOfObject>CodeList</r:TypeOfObject>
  </r:CodeListReference>
</r:CodeRepresentation>
```

The idea is to check if the data value is included whithin a list of code values. The corresponding VTL rule is as follow where `code_decl` is the name of the instance variable:
```
rule_code_decl : code_decl in {"11","14"} errorcode "Code value not valid";
```


