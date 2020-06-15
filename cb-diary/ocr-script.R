library(magick)
library(magrittr)
library(tesseract)

imgsource <- "og-pages"
myfiles <- list.files(path = imgsource, pattern = "jpg", full.names = TRUE)

lapply(myfiles, function(i){
  text <- image_read(i) %>%
    image_resize("3000x") %>%
    image_convert(type = 'Grayscale') %>%
    image_trim(fuzz = 40) %>%
    image_write(format = 'png', density = '300x300') %>%
    tesseract::ocr()
  
  cat(text, file="complete-diary.txt", append=TRUE, sep="\n")
  
})
