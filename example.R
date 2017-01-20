library(ggplot2)


source('rtt_gen.R')

main.dir <- getwd()
data.dir <- file.path(main.dir, 'data/')
graph.dir <- file.path(main.dir, 'graph/')

ifelse(!dir.exists(data.dir), dir.create(data.dir), F)
ifelse(!dir.exists(graph.dir), dir.create(graph.dir), F)

for (i in 1:100){
  rtt <- rtt.gen(1000)
  setwd(data.dir)
  write.table(rtt, row.names = F, file = sprintf("%d.csv", i), dec = '.', sep=';')
  setwd(graph.dir)
  pdf(sprintf("%d.pdf", i), width = 12, height = 6)
  g <- ggplot(rtt, aes(x=seq_len(nrow(rtt)), y=trace)) +
    geom_line(size=.3) +
    geom_vline(xintercept = which(rtt$cpt == 1), col='red', size=1, alpha=.4) +
    xlab("Index") +
    ylab("RTT (ms)") +
    theme(text=element_text(size=20))
  print(g)
  dev.off()
}