## Processes all runs for pressure, Um, Ux, and Uy. 
#

#### Parameter definitions ####
n <- 165
num <- 3
track <- "obstacles"         # Options: "racetrack", "branch", "obstacles", "branchandobstacles"

outputs <- c("aorta_Um", "aorta_Ux",
             "connect_Um", "connect_Uy", 
             "vena_Um", "vena_Ux",
             "aorta_P", "vena_P")
types <- c("avg","max")

parameters <- read.table(paste("./data/parameters/allpara_", n, ".txt", sep = ""), sep = "\t")
# allocate space
allofit <- matrix(0, n, length(outputs) * length(types) + 5)
allofit[, 1] <- seq(1,n)
allofit[, 2] <- parameters$V1
allofit[, 3] <- parameters$V2
allofit[, 4] <- parameters$V3
parameter_names<-c("Wo", "CR", "Freq")

#### Function definitions ####
get.data <- function(i, track, output, type){
  data <- read.table(paste("./results/visit/", track, "_runs/sim",i,"/", 
                           output, "_", type, ".curve", sep = ""), header = FALSE)
  return(data)
}

#### Main loop #### 
for (i in 1:num){
  print(paste("Simulation:",i))
  sample_data <- get.data(i, track, outputs[1], types[1])
  allofit_ts <- matrix(0, length(sample_data$V1), length(outputs) * length(types) + 1)
  allofit_ts[,1] <- sample_data$V1
  legend_names<-rep("a",length(outputs) * length(types))
  for(j in 1:length(outputs)){
    for(k in 1:length(types)){
      data <- get.data(i, track, outputs[j], types[k])
      allofit_ts[,((2 * j - 1) + k)] <- data$V2
      legend_names[((2 * j - 2) + k)] <- paste(outputs[j], types[k], sep = "_")
      if (k == 1){
        allofit[i,((2 * j - 2) + k)+4] <- mean(data$V2)
      }else if (k==2){
        allofit[i,((2 * j - 2) + k)+4] <- max(data$V2)
      }else {
        print("Error!")
      }
    }
  }
  allofit[i,length(outputs) * length(types) + 5] <- 
    allofit[i, length(outputs) * length(types) - 4] - 
    allofit[i, length(outputs) * length(types)]
  allnames <- c("time",legend_names)
  colnames(allofit_ts) <- allnames
  write.table(allofit_ts, file = paste("./results/r-csv-files/", 
                                    track, "_results/time_series_sim", i, ".csv", sep = ""),
              sep = ",", row.names = FALSE, col.names = TRUE)
}
allnames2 <- c("number", parameter_names, legend_names, "delta_P")
colnames(allofit) <- allnames2
write.table(allofit, file = paste("./results/r-csv-files/", 
                                  track, "_results/combined_data_", track, "_", num, "_", Sys.Date(), ".csv", sep = ""), 
            sep = ",", row.names = FALSE, col.names = TRUE)

