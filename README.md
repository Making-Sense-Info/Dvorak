# Dvořák

[DDI](https://ddialliance.org/) to [VTL](https://sdmx.org/?page_id=5096) exploratory work.

This allows VTL rules to be generated to check data conformity with its documentation expressed in DDI.

The generation process takes as input a DDI PhysicalInstance expressed in 3.3 DDI XML file using DDI Fragment Instance and generates a text file containing VTL rules. The process is split into two steps: 

1. `dereference` building an XML file containing a dereferenced Physical Instance 
2. `ddi2vtl` generating text file containing VTL rules

The generation process can be represented as follow:

![](./img/vtl-generation-process.svg)

For more details on transformation, see the [specification](./specification.md).

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

DDI input is a 3.3 DDI XML file. A [DDI PhysicalInstance](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/PhysicalInstance/) must be the top-level reference of a Fragment Instance serialized atomically.
Two different models are supported:
1. one containing [InstanceVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/Variable/) referencing [RepresentedVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/RepresentedVariable/) with the DDI representation.
2. one containing [InstanceVariable](https://ddialliance.github.io/ddimodel-web/DDI-L-3.3/item-types/Variable/) serializing DDI representation inline

To test your own DDI file, perform the following steps:
1. Add your DDI file in `src/test/ddi` (e.g. `my-ddi-file.xml`)
2. Change the name of the source DDI file in the script `dereference` (e.g. change `physicalInstance-test.xml` to `my-ddi-file.xml`). If desired, you also can change the name of the generated file in the script `ddi2vtl`
3. Run both scripts `dereference` then `ddi2vtl` as mentionned in section "Get started"

## References

This work has been the subject of two presentations at international conferences:
- **Using data description to automate validation with VTL** at the [9th SDMX Global Conference](https://www.sdmx2023.org/)
  - [PDF medium of presentation](https://www.sdmx2023.org/plenary/SESSION_4/Thomas%20Dubois-%20Franck%20Cotton%20-%20FINAL.pdf)
  - [Video](https://youtu.be/7F9dQevApJA?t=9643)
- [**Documenting and validating administrative data with DDI**](https://zenodo.org/records/10259088) at the [15th Annual European DDI User Conference (EDDI 2023)](https://www.eddi-conferences.eu/)