#############################################################
# Script to download raw NEON data files
# This is the first step in a processing pipeline
# Kory Melton
# October 23, 2019
# kmelton@dons.usfca.edu
#############################################################

source("scripts/downloadRawSequenceData.R")

# download all of the raw sequence 16S data for the
# UNDE site and put it in the /data directory

rawdata_metadata <- downloadRawSequenceData(
        dpid = "DP1.10108.001",
        sites = "UNDE",
        targetGene = "16S",
        startYrMo = NA,
        endYrMo = NA,
        checkFileSize = FALSE,
        outdir = "/data")

# write out the metadata for all the samples to a
# csv file

write.csv(
        rawdata_metadata,
        "/data/rawdata_metadata.csv")
