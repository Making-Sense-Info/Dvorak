# Dvořák

DDI to VTL exploratory work. This allows VTL rules to be generated to check data conformity with its documentation expressed in DDI.

## Install

- clone the repository
- create a `/lib` folder and a `/target` folder, where `/` is the Git repository root
- download Saxon HE 11.4 from [GitHub](https://github.com/Saxonica/Saxon-HE/blob/main/11/Java/SaxonHE11-4J.zip) and extract all files in `/lib`

## Usage

### Get started

From the command line (or by double-clicking on the script)
```
cd src/main/scripts
"./dereference.bat"
```

The result will be in `/target/dereferenced.xml`.

Similarly, the `ddi2vtl` can be executed after `dereference` and will produce `/target/vtl.txt`.

See all available command line options in the [Saxon documentation](https://www.saxonica.com/documentation11/index.html#!using-xsl/commandline).

### Customized usage

DDI is a 3.2 DDI XML file. A [DDI PhysicalInstance](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/PhysicalInstance/) must be the top-level reference of a Fragment Instance serialized atomically.
Two different models are supported:
1. one containing [InstanceVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/Variable/) referencing [RepresentedVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/RepresentedVariable/) with the DDI representation.
2. one containing [InstanceVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/Variable/) serializing DDI representation inline

To test your own DDI file, perform the following steps:
1. Add your DDI file in `src/test/ddi` (e.g. `my-ddi-file.xml`)
2. Change the name of the source DDI file in the script `dereference` (e.g. change `physicalInstance-test.xml` to `my-ddi-file.xml`). If desired, you also can change the name of the generated file in the script `ddi2vtl`
3. In case of the DDI model option 2, in the script `src\main\xslt\ddi2vtl.xsl`:
  - Comment the xsl variable 
  ```xml
  <!-- <xsl:variable name="representation">l:RepresentedVariable/r:CodeRepresentation | l:RepresentedVariable/r:DateTimeRepresentation/r:DateTypeCode | l:RepresentedVariable/r:TextRepresentation | l:RepresentedVariable/r:NumericRepresentation/r:NumericTypeCode</xsl:variable> -->
  ```
  - and uncomment the xsl variable
  ```xml
  <xsl:variable name="representation" select="'l:RepresentedVariable'"/>
  ```xml
4. Run both scripts `dereference` then `ddi2vtl` as mentionned in section "Get started"
