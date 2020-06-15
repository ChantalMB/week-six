library(rvest)
library(RSelenium)

rD <- rsDriver(port=4444L, browser="chrome", chromever="83.0.4103.39")
remDr <- rD$client

#rD$server$stop()


remDr$navigate("https://transcription.si.edu/project/7362")

for(i in 1:25){      
  remDr$executeScript(paste("scroll(0,",i*10000,");"))
  Sys.sleep(3)    
}

page_source<-remDr$getPageSource()

print(page_source[[1]])

item <- list()

item[[1]] <- page_source[[1]]

pages <- sapply(item, function(x) {x %>% read_html() %>% html_nodes("a[href*='/view/7362/']") %>% html_attr("href")})

print(pages)

output <- list()

print(length(pages))

for(row in 1:nrow(pages)){
  for(col in 1:ncol(pages)){
    fullURL <- paste("https://transcription.si.edu", pages[row], sep = "")
    output <- c(output, fullURL)
  }
}

for(i in output) {
  navi <- paste(i, sep="")
  
  remDr$navigate(navi)
  
  page_source<-remDr$getPageSource()
  
  item <- list()
  
  print(item)
  
  item[[1]] <- page_source[[1]]
  
  pages <- sapply(item, function(x) {x %>% read_html() %>% html_nodes("pre") %>% html_text()})
  
  file_name <- sapply(item, function(x) {x %>% read_html() %>% html_nodes("#transcription-asset-wrapper") %>% html_attr("data-idsid")})
  
  file_name <- gsub(".*AAA_","",file_name)
  
  print(file_name)
  
  output <- list()
  
  for(row in pages){
    entry <- paste(file_name, row, sep="-->       ")
    output <- c(output, entry)
  }
  
  lapply(output, write, "diary-pgref.txt", append=TRUE)
}

rD$server$stop()
