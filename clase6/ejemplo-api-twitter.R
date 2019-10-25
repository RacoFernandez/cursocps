install.packages("ROAuth")
install.packages("twitteR")
library("ROAuth")
library("twitteR")
options(RCurlOptions = list( capath = system.file("CurlSSL", "cacert.pem", package = "RCurl"), ssl.verifypeer = FALSE))
reqURL<-"https://api.twitter.com/oauth/request_token"
accessURL<-"https://api.twitter.com/oauth/access_token"
authURL<-"https://api.twitter.com/oauth/authorize"
#cargo mis credenciales de developer twitter
consumerKey<-""
consumerSecret<-"" #Idem
access_token <- ""
access_secret <- ""
setup_twitter_oauth(consumerKey, consumerSecret, access_token, access_secret)
#Generamos un environment
tmp.env <- new.env()
#con Searchtwitter pedimos los tweets con un determinado string (en este caso un hashtag) con un n y una fecha (limite de la API gratuita son 8 dias)
tmp.env$tweets.nm1 <- searchTwitter("#sisepuede", n=7000, since="2019-10-17")
#Convierto mi twitter list (generada por la query) en un dataframe
tweets.df1 <- twListToDF(tmp.env$tweets.nm1)
View(tweets.df1)
#Tomamos tweets de un solo usuario
user1="@realdonaldtrump"
tmp.env$tweets.trump<-userTimeline(user = user1, n=2000)
tweets.df2 <- twListToDF(tmp.env$tweets.trump)
View(tweets.df2)
#aplicamos algunas tecnicas basicas de mineria de texto
tmp.env$tweets.nm1 <- searchTwitter("#sisepuede", n=10000, since="2019-10-17")
no_retweets = strip_retweets(tmp.env$tweets.nm1)
tweets.df3 <- twListToDF(no_retweets)
install.packages("tm")
install.packages("SnowballC")
install.packages("wordcloud")
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
#http://www.sthda.com/english/wiki/text-mining-and-word-cloud-fundamentals-in-r-5-simple-steps-you-should-know
docs <- Corpus(VectorSource(tweets.df3$text))
# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# sacamos las stopwords en español
docs <- tm_map(docs, removeWords, stopwords("spanish"))
# Remove your own stop word
# podemos especificar stopwords
docs <- tm_map(docs, removeWords, c("radicalismo"))
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
docs <- tm_map(docs, stemDocument)
#matriz termino documentos
dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)
#ploteo la nube de palabras
set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))
rm(tmp.env)  #cerramos el espacio temporal


