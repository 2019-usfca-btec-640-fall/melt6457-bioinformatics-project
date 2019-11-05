## Function downloads the metadata for various sequencing data products and
## downloads the raw data files

# nolint start
downloadRawSequenceData <- function(dpid = "",
                                    targetGene = "16S",
                                    sites = "all",
                                    startYrMo = "YYYY-MM",
                                    endYrMo = "YYYY-MM",
                                    outdir = "",
                                    checkFileSize = TRUE,
                                    download = TRUE) {
  # Outputs: 1) data frame of raw data records of interest;
  # Outputs: 2) raw sequence data, if download=TRUE
  # dpid - a valid data product ID, format "DP1.xxxxx.001"
  # targetGene - options are "16S" or "ITS"
  # sites - a vector of the sites to download, "all" gets data from all sites
  # outdir - path to directory to ouput the data. Defaults to the R default
  #   directory if none provided
  # checkFileSize - if TRUE, then user will be prompted to select y or n
  #   during metadata download. (options TRUE or FALSE)
  # download - indicates whether sequence data should be automatically
  #   downloaded (options TRUE or FALSE)

  # load libraries #
  if (!"neonUtilities" %in% row.names(installed.packages())) {
    install.packages("neonUtilities")
    }
  library(neonUtilities)
  library(utils)
  library(plyr)
  library(dplyr)

  # check outdir value #
  if (outdir == "") {
    outdir <- paste0(getwd(), "/")
    print(paste("No output directory provided. Defaulting to", outdir))
  }

  # check dpid value #
  if (grepl("^DP1.", dpid) == FALSE) {
    stop("Invalid dpid format, must begin with 'DP1.' ")
  }
  if (grepl("\\.001$", dpid) == FALSE) {
    stop("Invalid dpid format, must end with '.001' ")
  }

  okids <- c("DP1.10108.001", "DP1.20280.001", "DP1.20282.001")

  if (dpid %in% okids == FALSE) {
    stop("No sequence data exist for this dpid")
  }

  # download data product from NEON API #
  print(
    "Grabbing metadata from the NEON Data Portal. This may take a few moments")
  dat <- loadByProduct(dpID = dpid,
                       site = sites,
                       startdate = startYrMo,
                       enddate = endYrMo,
                       package = "expanded",
                       check.size = checkFileSize)

  # Filter records to 16S or ITS
  df <- plyr::ldply(dat, data.frame)
  names(df)[names(df) == ".id"] <- "tableID"

  rawDat <- df[grep("Raw", df$tableID), ]
  rawDat <- Filter(function(x)!all(is.na(x)), rawDat)

  if (targetGene == "16S") {
    if (any(grepl("_ITS_", rawDat$rawDataFileName)))
       rawDat <- rawDat[ -(grep("_ITS_", rawDat$rawDataFileName)), ]
  }

  if (targetGene == "ITS") {
    if (any(grepl("_16S_", rawDat$rawDataFileName)))
      rawDat <- rawDat[ -(grep("_16S_", rawDat$rawDataFileName)), ]
  }

  # Extract unique URLs #
  u.urls <- unique(rawDat$rawDataFilePath)
  fileNms <- gsub("^.*\\/", "", u.urls)

  ## get file sizes ##
  fileSize <- NA
  print("Grabbing sizes of sequence files")
  for (i in seq_len(u.urls)) {
    response <- httr::HEAD(as.character(u.urls[i]))
    fileSize[i] <- round(as.numeric(
      httr::headers(response)[["Content-Length"]]) / 1048576, 1) # bytes to MB
  }
  # Report number and sizes of files to download #
  print(paste("There are", length(u.urls),
              "unique files to download, total space required:",
              sum(fileSize), "MB"))

  # Download files #
  if (download == TRUE) {
    print("Downloading all unique files")
    for (i in seq_len(u.urls)) {
      download.file(url = as.character(u.urls[i]),
                    destfile = paste(outdir, fileNms[i], sep = "/"))
    }
  }

  return(rawDat)
  ## END FUNCTION ##
}

# nolint end
