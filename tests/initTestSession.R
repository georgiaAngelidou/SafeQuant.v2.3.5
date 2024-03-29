# TODO: Add comment
#
# Author: ahrnee-adm
###############################################################################

### load / source

library(UniProt.ws)
library(GO.db)
library(stringr)
library("limma")
library(gplots) # volcano plot
library(seqinr)
library(optparse)
library(data.table)
library(epiR)
library(corrplot)
library(Biobase)
library(ggplot2)
library(magrittr)
library(ggrepel)
library(plotly)
library(Hmisc)
library(dplyr)

### INIT
if(!grepl("SafeQuant\\.Rcheck",getwd())){ # DEV mode
	wd <- dirname(sys.frame(1)$ofile)
	setwd(dirname(sys.frame(1)$ofile))
	sqRootDir <- dirname(getwd())

	source(paste0(sqRootDir,"/R/ExpressionAnalysis.R"))
	source(paste0(sqRootDir,"/R/SafeQuantAnalysis.R"))
	source(paste0(sqRootDir,"/R/Graphics.R"))
	source(paste0(sqRootDir,"/R/IdentificationAnalysis.R"))
	source(paste0(sqRootDir,"/R/Parser.R"))
	source(paste0(sqRootDir,"/R/TMT.R"))
	source(paste0(sqRootDir,"/R/UserOptions.R"))
	source(paste0(sqRootDir,"/R/Targeted.R"))

	source(paste0(sqRootDir,"/R/GGGraphics.R"))
	source(paste0(sqRootDir,"/R/DIA.R"))

	load(paste0(sqRootDir,"/data/kinaseMotif.rda"))

}else{ # CHECK mode
	### wd already set to tests when running CHECK
	library(SafeQuant)
}



### INIT
### VARIOUS TEST FILES

# progenesis
progenesisFeatureCsvFile1 <- "testData/progenesis_feature_export1.csv"
progenesisPeptideMeasurementCsvFile1 <- "testData/progenesis_pep_measurement1.csv"

#progenesisPeptideMeasurementCsvFile1 <- "testData/tmp.csv"

progenesisProteinCsvFile1 <- "testData//progenesis_protein_export1.csv"
progenesisPeptideMeasurementFractionatedCsvFile1 <- "testData/progenesis_pep_measurement_fractionated1.csv"

#progenesisProteinCsvFile2 <- "testData/2014/proteins2.csv"
#progenesisFeatureCsvFile2 <- "testData/2014/peptides2.csv"


# scaffold
scaffoldTmt6PlexRawTestFile <- "testData/scaffold_tmt6plex_raw.xls"
scaffoldTmt10PlexRawTestFile <- "testData/scaffold_tmt10plex_raw.xls"
scaffoldTmt10PlexCalibMixRawTestFile <- "testData/scaffold_tmt10plex_calibMix_raw.xls"

#scaffoldPtmTMTRawDataFile1 <- "testData/scaffoldPTM/Christoph-LE-Human-pH10fraction-TMT-20150630/Raw Data Report for Christoph-LE-Human-pH10fraction-TMT-20150630.xls"
#scaffoldPtmReportFile1 <- "testData/scaffoldPTM/Christoph-LE-Human-pH10fraction-TMT-20150630/Spectrum Report of Scaffold_PTM_P-TMT-pH10 Experiment.xls"
scaffoldPtmTMTRawDataFile1 <- "testData/scaffold_tmt10plex_raw_phospho.xls"
scaffoldPtmReportFile1 <- "testData/scaffoldPtm_spectrum_report.xls"

# maxquant
maxQuantProteinFileTxt <- "testData/maxquant_protein_groups.csv"

# db
fastaFile <- "testData/mouse_proteins.fasta"

# phospho motif
phosphoMotifFile <- "testData/motifs.xls"

### INIT END

## CREATE TEST DATA

set.seed(1234)
nbFeatures <- 900

peptide <- paste("pep",1:nbFeatures,sep="")
peptide[1] <- "VALGDGVQLPPGDYSTTPGGTLFSTTPGGTR"
peptide[2] <- "AQAGLTATDENEDDLGLPPSPGDSSYYQDQVDEFHEAR"

proteinName <- sort(rep(paste("prot",1:(nbFeatures/3),sep=""),3))
proteinName[1:200] <- paste("REV_",proteinName[1:200] ,sep="")
proteinName[1] <- "sp|Q60876|4EBP1_MOUSE"
proteinName[2] <- "sp|Q9JI13|SAS10_MOUSE"

idScore <- rep(0,length(proteinName))
idScore[1:200] <-rnorm(200,10,1)
idScore[c(1:2,201:900)] <- rnorm(702,15,1)

ptm <- rep("",900)
ptm[1] <- "[15] Phospho (ST)|[30] Phospho (ST)"
ptm[2] <- "[20] Phospho (ST)"

pMassError <- c(rnorm(200,0,1.5),rnorm(700,0,0.5))

charge <- round(runif(length(ptm),1.5,3.7))

peptideName <- paste(peptide,ptm)

proteinDescription <- sort(rep(paste("protDescription",1:(nbFeatures/3),sep=""),3))
isNormAnchor <- rep(T,nbFeatures)
isFiltered <- rep(F,nbFeatures)

m <- as.matrix( data.frame(rnorm(nbFeatures,1001),rnorm(nbFeatures,1001),rnorm(nbFeatures,1002),rnorm(nbFeatures,1002),rnorm(nbFeatures,1000),rnorm(nbFeatures,1000)) )
rownames(m) <- peptideName
colnames(m) <- c("A_rep_1","A_rep_2","B_rep_1","B_rep_2","C_rep_1","C_rep_2")

### phenoData: stores expDesign
#condition isControl
#A_rep_1         A     FALSE
#A_rep_2         A     FALSE
#B_rep_1         B     FALSE
#B_rep_2         B     FALSE
#C_rep_1         C      TRUE
#C_rep_2         C      TRUE

expDesign <- data.frame(condition=c("A","A","B","B","C","C"),isControl=c(F,F,F,F,T,T),row.names=colnames(m))
#expDesign <- data.frame(condition=c("A","A","B","B","C","C"),row.names=colnames(m))

featureAnnotations <- data.frame(
		 peptide
		, charge
		,proteinName
		,ac = NA
		,geneName = NA
		,proteinDescription
		,idScore
		,ptm
		,pMassError
		,isNormAnchor
		,isFiltered
		,row.names=peptideName)

eset <- createExpressionDataset(expressionMatrix=m,expDesign=expDesign,featureAnnotations=featureAnnotations)


sqa <- safeQuantAnalysis(eset)

# ABS. QUANT SIM. DATA
cpc <- rep(2^(1:5),10)
set.seed(1234)
signal <- rnorm(length(cpc),cpc,cpc/10)
absEstSimData <- data.frame(cpc =  log10(cpc),signal = log10(signal))
absEstSimDataFit <- lm(cpc ~ signal, data=absEstSimData )


### CREATE PAIRED ESET
set.seed(1234)
esetPaired <- eset
exprs(esetPaired)[,1] <- rnorm(nrow(exprs(eset)),1500,1500/10)
exprs(esetPaired)[,2] <- rnorm(nrow(exprs(eset)),3000,3000/10)
exprs(esetPaired)[,3] <- rnorm(nrow(exprs(eset)),1200,1200/10)
exprs(esetPaired)[,4] <- rnorm(nrow(exprs(eset)),2400,2400/10)
exprs(esetPaired)[,5] <- rnorm(nrow(exprs(eset)),1000,1000/10)
exprs(esetPaired)[,6] <- rnorm(nrow(exprs(eset)),2000,2000/10)
esetPaired <- createPairedExpDesign(esetPaired)


##### TMT
### CREATE TEST DATA

tmtTestData6Plex <- matrix(rep(10,24),ncol=6)
tmtTestData6Plex[2,1:3] <- c(9,9,9)
tmtTestData6Plex[3,1:3] <- c(100,100,100)
tmtTestData6Plex[4,c(1,3,5)] <- c(100,100,100)

tmtTestData10Plex <- matrix(rep(10,100),ncol=10)

esetCalibMix <- parseScaffoldRawFile(file=scaffoldTmt10PlexCalibMixRawTestFile
	,expDesign=data.frame(condition=paste("Condition",c(1,2,3,1,2,3,1,2,3,1),sep=""),isControl=c(T,F,F,T,F,F,T,F,F,T) ))

#esetCalibMixPair <- .getCalibMixPairedEset(.getCalibMixEset(esetCalibMix))

### CREATE TEST DATA END

