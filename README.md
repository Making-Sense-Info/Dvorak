# Dvořák

DDI to VTL exploratory work

## Install

- clone the repository
- create a `/lib` folder and a `/target` folder, where `/` is the Git repository root
- donwload Saxon HE 11.4 from [GitHub](https://github.com/Saxonica/Saxon-HE/blob/main/11/Java/SaxonHE11-4J.zip) and extract all files in `/lib`

## Usage

### From the command line

```
cd src/main/scripts
dereference
```

The result will be in `/target/dereferenced.xml`.

Similarly, the `ddi2vtl` can be executed after `dereference` and will produce `/target/vtl.txt`.

See all available command line options in the [Saxon documentation](https://www.saxonica.com/documentation11/index.html#!using-xsl/commandline).

