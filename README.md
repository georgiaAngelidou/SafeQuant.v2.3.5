The SafeQuant package was originally develop by https://github.com/eahrne/SafeQuant.

New features were included in the version provided by https://github.com/georgiaAngelidou/safeQuant/new/main.

The new feature includes supporting different file format and set the experimental design through a .txt file.

## Installation

**1. Install Dependecies**

A) By using the installationCode.R

Open the R or RStudio and Run the following 
	
	# information to install SafeQuant

	R> install.packages("seqinr")
	R> install.packages("gplots") # maybe it will cause some issue
	R> install.packages("corrplot")
	R> install.packages("optparse")
	R> install.packages("data.table")
	R> install.packages("epiR")
	R> install.packages("ggplot2")
	R> install.packages("ggrepel")
	R> install.packages("BiocManager")
	R> BiocManager::install(c("limma", "affy", 'UniProt.ws', "GO.db", "impute", "pcaMethods"))
	R> install.packages("devtools")
	
B) Use the already set environment store in the folder renv
**Download** the full project or the folders "exec" and "renv" from the github directory and save them **in the same directory**.

Open R or Rstudio and set the directory where you save the 2 folders or the full project as your working directory.

	R> setwd("D:/proteomics/SafeQuant")

If you don't already have the packages "renv" installed in your R environment, install it by using the following command:

	R> install.packages("renv")

To activate the already prepare environment for the safeQuant you need to do the following:

	R> library("renv")
	R> renv::restore()
	R> renv::activate()
	
	
**Note 1:** 

If an error show up about the Bioconductor as in the photo below:

![image](https://user-images.githubusercontent.com/24875514/155146110-add4aa3b-b4f3-4c46-b928-edb3a8e7588a.png)

Then you should also type the following command:

	R> renv::init(bioconductor = TRUE)
	

**This it will give you the possibilite to run safeQuant without the need of installing all the packages but this will be possible only if you are inside the directory where you save both "exec" and "renv".**

If you are located in any other directory this will not be possible.

To be able to be in any other directory then you will need to follow the information from the 1.A).


**2) Install SafeQuant from sources**

**Option 1, install "master branch" using "devtools"**

Make sure you have a working development environment

Windows: Install Rtools

Mac: Install Xcode from the Mac App Store

Linux: Install a compiler and various development libraries (details vary across different flavors of Linux).

	R> install.packages("devtools")
	R> library("devtools")
	R> install_github("georgiaAngelidou/SafeQuant.v2.3.5")
	
**Option 2, install latest CRAN version.** This is the latest version found in the original github repository (https://github.com/eahrne/SafeQuant). 

	R> install.packages("SafeQuant")
	
**3) Running safeQuant.R**

A) locate file safeQuant.R (C:\Users\ahrnee-adm\Downloads\SafeQuant\exec\safeQuant.R ) This is the SafeQuant main script. Copy it to an appropriate directory, e.g. c:\Program Files\SafeQuant\

B) open termina To display help options

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R" -h

To run (with minimal arguments)

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R" -i "c:\Program Files\SafeQuant\testData\peptide_measurement.csv" -o "c:\Program Files\SafeQuant\out"

**Progenesis**

**Input file:** "Peptide Measurement".CSV file

- File -> Export Peptide Measurements. This option is available once you have reached the "Resolve Conflicts" Step in Progenesis QI
- When choosing properties to be included in the exported file check the "Grouped accessions (for this sequence)" check box.

**Scaffold (TMT, experimental suppost)**

**Input file:** "Raw Export".XLS

Note that the experimental design needs to be specified (column numbers refer to listing order in .txt).

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R"  -i ../../SafeQuantTestData/TMT_10-Plex_Scaffold_Raw_Export_Example.xls --EX 1,2,3,4,5:6,7,8,9,10
	
**MaxQuant**

**Input file:** proteinGroups.txt

Note that the experimental design needs to be specified. 
There two ways to specified the experimental design:

A) As it was set original (column numbers refer to listing order in .txt).

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R"  -i ../../SafeQuantTestData/misc/maxQuant/proteinGroups.txt --EX 1,2,3:6,7,8 

B) By the new experimental design by providing an experimentalDesign.txt (see a section further how to create the file).

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R"  -i ../../SafeQuantTestData/misc/maxQuant/proteinGroups.txt --EX ../../SafeQuantTestData/misc/maxQuant/experimentalDesign.txt
	
**Spectronant (Experimental support)**

**Input file:** "Spectronant Protein Group".xlsx

Note that the experimental design needs to be specified by providing an experimentalDesign.txt (see a section further how to create the file).

	> Rscript "c:\Program Files\SafeQuant\safeQuant.R"  -i ../../SafeQuantTestData/misc/maxQuant/spectronant_proteinGroups.xlsx --EX ../../SafeQuantTestData/misc/maxQuant/experimentalDesign.txt
	
	
**DIA-NN (COMING SOON)**

**Basic functionality of the safeQuant.R script**

1. Data Normalization
	- LFQ
		- Global data normalization by equalizing the total MS1 peak areas across all LC/MS runs.
	- Isobaric Labeling experiments (TMT or iTRAQ)
		- Global data normalization by equalizing the total reporter ion intensities across all reporter ion channels.
2. Ratio Calculation
	- LFQ
		- Summation of MS1 peak per peptide/protein and LC-MS/MS run, followed by calculation of peptide/protein abundance ratios.
	- Isobaric Labeling experiments (TMT or iTRAQ)
		- Summation of reporter ion intensities per peptide/protein and LC-MS/MS run, followed by calculation of peptide/protein abundance ratios.
3. Statistical testing for differetnial abundances
	- The summarized peptide/protein expression values are used for statistical testing between condition differentially abundant peptides/proteins. Here, empirical Bayes moderated t-tests is applied, as implemented in the R/Bioconductor limma package (Smyth, 2004). The resulting per protein and condition comparison p-values are subsequently abjusted for multiple testing using the Benjamini-Hochberg method.

Smyth, G. K. (2004). Linear models and empirical bayes methods for assessing differential expression in microarray experiments. Stat Appl Genet Mol Biol, 3 SP -Article3. http://www.ncbi.nlm.nih.gov/pubmed/16646809

**Use Case Manual**

https://raw.githubusercontent.com/eahrne/SafeQuant/master/inst/manuals/SafeQuant_UseCases.txt

.tsv export help

https://github.com/eahrne/SafeQuant/blob/master/inst/manuals/tsv_spreadsheet_help.pdf

Package Documentation

https://github.com/eahrne/SafeQuant/blob/master/inst/manuals/SafeQuant-man.pdf

Publications

- Ahrne, E. et al. Evaluation and Improvement of Quantification Accuracy in Isobaric Mass Tag-Based Protein Quantification Experiments. J Proteome Res 15, 2537-2547 (2016). https://www.ncbi.nlm.nih.gov/pubmed/27345528
- Ahrne, E., Molzahn, L., Glatter, T., & Scmidt, A. (2013). Critical assesment of proteome-wide label0free absolute abundance estimation strategies. Proteomics. Journal of Proteome Research Just Accepted Manuscript https://www.ncbi.nlm.nih.gov/pubmed/23794183
- Glatter, T., Ludwig, C., Ahrne. E., Aebersold, R., Heck, A. J. R., & Schmidt, A. (2012). Large-scale quantitative assessment of different in-solution protein digestion protocols reveals superior cleavage efficiency of tandem Lys-C/trypsin proteolysis over trypsin digestion. https://www.ncbi.nlm.nih.gov/pubmed/23017020

