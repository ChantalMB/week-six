library(tidyverse)
library(tidytext)

library("reshape2")
library("ggplot2")

cb  <- read_csv("diary.csv")

cb_df <- tibble(id = cb$entry, date = cb$date, text = (str_remove_all(cb$text, "[0-9]")))

tidy_cb <- cb_df %>%
  unnest_tokens(word, text)

data(stop_words)

tidy_cb <- tidy_cb %>%
  anti_join(stop_words)

cb_words <- tidy_cb %>%
  count(id, word, sort = TRUE)

dtm <- cb_words %>%
  cast_dtm(id, word, n)

require(topicmodels)

K <- 15

set.seed(9161)
topicModel <- LDA(dtm, K, method="Gibbs", control=list(iter = 500, verbose = 25))

tmResult <- posterior(topicModel)

attributes(tmResult)

ncol(dtm)

beta <- tmResult$terms
dim(beta)

theta <- tmResult$topics
dim(theta)        

top5termsPerTopic <- terms(topicModel, 5)
topicNames <- apply(top5termsPerTopic, 2, paste, collapse=" ")
topicNames

# patterns in text
# tried to sample data evenly from throughout year --> randomly picked entries from csv
exampleIds <- c(57, 169, 317)

N <- length(exampleIds)

topicProportionExamples <- theta[exampleIds,]
colnames(topicProportionExamples) <- topicNames

vizDataFrame <- melt(cbind(data.frame(topicProportionExamples), document = factor(1:N)), variable.name = "topic", id.vars = "document")  

ggplot(data = vizDataFrame, aes(topic, value, fill = document), ylab = "proportion") +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +  
  coord_flip() +
  facet_wrap(~ document, ncol = N)


# tm over time
topic_proportion_in_year <- aggregate(theta, by = list(month = cb$month), mean)


colnames(topic_proportion_in_year)[2:(K+1)] <- topicNames

vizDataFrame <- melt(topic_proportion_in_year, id.vars = "month")


require(pals)
ggplot(vizDataFrame, aes(x=month, y=value, fill=variable)) +
  geom_bar(stat = "identity") + ylab("proportion") +
  scale_fill_manual(values = paste0(alphabet(15), "FF"), name = "month") +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))




