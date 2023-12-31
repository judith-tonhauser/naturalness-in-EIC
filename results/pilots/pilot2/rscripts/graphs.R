# 13_explicitIgnorance
# graphs

# set working directory to directory of script
this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

# load required packages
require(tidyverse)
library(ggrepel)
library(dichromat)
library(forcats)
library(ggrepel)

# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

theme_set(theme_bw())

# load helper functions
source('../../../helpers.R')

d = read_tsv("../data/cd.tsv")

names(d)
table(d$context)

# plot of mean naturalness ratings in explicit ignorance context ----

# target data: explicit ignorance context
t = d %>%
  filter(context == "explicitIgnorance")

# calculate mean naturalness rating by expression, including the controls
nat.means = t %>%
  group_by(expression) %>%
  summarize(Mean = mean(response), CILow = ci.low(response), CIHigh = ci.high(response)) %>%
  mutate(YMin = Mean - CILow, YMax = Mean + CIHigh, expression = fct_reorder(as.factor(expression),Mean))
nat.means

# plot of naturalness means, with participants' individual responses
ggplot(nat.means, aes(x=expression, y=Mean)) +
  geom_point(shape=21,stroke=.5,size=2.5,color="black") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=0.1,color="black") +
  geom_point(data = t[t$context == "explicitIgnorance",], aes(x=expression, y=response), shape=21,fill="gray60", alpha=.5, color="gray40") +
  scale_y_continuous(limits = c(0,1),breaks = c(0,0.2,0.4,0.6,0.8,1.0)) +
  scale_alpha(range = c(.3,1)) +
  guides(fill=FALSE) +
  theme(text = element_text(size=12), axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) +
  theme(legend.position="top") +
  ylab("Mean naturalness \n explicit ignorance context") +
  xlab("Expression") +
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) 
ggsave("../graphs/explicit-ignorance-naturalness-by-predicate.pdf",height=4,width=7)

# plot of mean naturalness ratings in explicit ignorance and neutral context ----
# for 20 clause-embedding predicates only

# calculate mean naturalness rating by expression and context
table(d$expression)
nat.means = d %>%
  filter(expression != "controlGood1" & expression != "controlGood2" & expression != "controlGood3" & expression != "controlGood4") %>%
  filter(expression != "also" & expression != "too" & expression != "again" & expression != "cleft" &
         expression != "stop" & expression != "continue") %>%
  mutate(context2 = recode(context, "factL" = "neutral", "factH" = "neutral")) %>%
  group_by(expression,context2) %>%
  summarize(Mean = mean(response), CILow = ci.low(response), CIHigh = ci.high(response)) %>%
  mutate(YMin = Mean - CILow, YMax = Mean + CIHigh) %>%
  select(-c(CILow,CIHigh))
nat.means
nat.means$expression <- as.factor(nat.means$expression)
str(nat.means$expression)

# sort expressions by naturalness rating in explicit ignorance context
tmp = nat.means %>%
  select(expression, context2, Mean) %>%
  filter(context2 == "explicitIgnorance") %>%
  mutate(Mean = ifelse(is.na(Mean), 0, Mean)) %>%
  ungroup() %>%
  mutate(expression = fct_reorder(expression, Mean))
tmp
table(tmp$expression)
str(tmp$expression)
levels(tmp$expression)

nat.means$expression = factor(nat.means$expression, levels=tmp$expression[order(tmp$expression)], ordered=TRUE)
levels(nat.means$expression)

# sort expressions by difference between ratings in the two contexts
tmp = nat.means %>%
  select(expression, context2, Mean) %>%
  pivot_wider(names_from = context2, values_from = Mean) %>%
  mutate(diff = explicitIgnorance - neutral) %>%
  mutate(diff = ifelse(is.na(diff), 0, diff)) %>% # remove this with full data
  ungroup() %>%
  mutate(expression = fct_reorder(expression, diff))
tmp
table(tmp$expression)
str(tmp$expression)
levels(tmp$expression)

nat.means$expression = factor(nat.means$expression, levels=tmp$expression[order(tmp$diff)], ordered=TRUE)
levels(nat.means$expression)

# plot
ggplot(nat.means, aes(x=expression, y=Mean, group = context2, fill = context2)) +
  geom_bar(stat="identity", color = "black", position=position_dodge(.9)) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=0.1,color="black", position=position_dodge(.9)) +
  scale_y_continuous(limits = c(0,1),breaks = c(0,0.2,0.4,0.6,0.8,1.0)) +
  scale_fill_manual(values=c('#E69F00','#999999'), name = "Context") + 
  #guides(fill=FALSE) +
  theme(text = element_text(size=12), axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) +
  theme(legend.position="top") +
  ylab("Mean naturalness rating") +
  xlab("Expression") +
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) 
ggsave("../graphs/naturalness-by-context-and-predicate.pdf",height=4,width=7)

# plot of mean naturalness ratings in neutral context ----
# no explicit ignorance context
nt = d %>%
  filter(context != "explicitIgnorance")

# calculate mean naturalness rating by expression, including the controls
nat.means.N = nt %>%
  group_by(expression) %>%
  summarize(Mean = mean(response), CILow = ci.low(response), CIHigh = ci.high(response)) %>%
  mutate(YMin = Mean - CILow, YMax = Mean + CIHigh, expression = fct_reorder(as.factor(expression),Mean))
nat.means.N
levels(nat.means.N$expression)

# plot of naturalness means
ggplot(nat.means.N, aes(x=expression, y=Mean)) +
  geom_point(shape=21,stroke=.5,size=2.5,color="black") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=0.1,color="black") +
  geom_point(data = nt[nt$context != "explicitIgnorance",], aes(x=expression, y=response), shape=21,fill="gray60", alpha=.5, color="blue") +
  scale_y_continuous(limits = c(0,1),breaks = c(0,0.2,0.4,0.6,0.8,1.0)) +
  scale_alpha(range = c(.3,1)) +
  guides(fill=FALSE) +
  theme(text = element_text(size=12), axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) +
  theme(legend.position="top") +
  ylab("Mean naturalness rating in neutral context") +
  xlab("Expression") +
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) 
ggsave("../graphs/neutral-context-naturalness-by-predicate.pdf",height=4,width=7)

# plot of mean naturalness ratings against mean certainty ratings

# get data from Degen & Tonhauser, 2022 (Language)
# https://github.com/judith-tonhauser/projective-probability/tree/master/results/5-projectivity-no-fact
dt <- read_csv("https://raw.githubusercontent.com/judith-tonhauser/projective-probability/master/results/5-projectivity-no-fact/data/cd.csv")
summary(dt)
table(dt$verb)

# target data
dt <- dt %>%
  filter(verb != "MC")
table(dt$verb)

dt.means = dt %>%
  group_by(verb) %>%
  summarize(MeanCertain = mean(response), CILow = ci.low(response), CIHigh = ci.high(response)) %>%
  mutate(YMinCertain = MeanCertain - CILow, YMaxCertain = MeanCertain + CIHigh, expression = fct_reorder(as.factor(verb),MeanCertain))
dt.means
levels(dt.means$expression)

# reduce the acceptability data to the 20 predicates
nat.means.EI = nat.means %>%
  filter(expression != "controlGood1" & expression != "controlGood2" & expression != "again"
         & expression != "also" & expression != "too" & expression != "continue"
         & expression != "stop" & expression != "cleft")

nat.means.EI
dt.means

# bind the data
data = left_join(nat.means.EI, dt.means, by = "expression")
data
summary(data)

# plot of naturalness means against certainty means
ggplot(data, aes(x=Mean, y=MeanCertain),label = expression) +
  geom_point(shape=21,stroke=.5,size=2,color="black") +
  geom_text_repel(aes(label = expression),
                   #box.padding   = 0.35, 
                   point.padding = 0.5,
                   segment.color = 'grey50') +
  geom_errorbarh(aes(xmin=YMin,xmax=YMax),height=.01,color="black") +
  geom_errorbar(aes(ymin=YMinCertain,ymax=YMaxCertain),width=.01,color="black") +
  #geom_point(data = nt[nt$context != "explicitIgnorance",], aes(x=expression, y=response), shape=21,fill="gray60", alpha=.5, color="blue") +
  scale_y_continuous(limits = c(0,1),breaks = c(0,0.2,0.4,0.6,0.8,1.0)) +
  guides(fill=FALSE) +
  geom_abline(intercept = 1,slope = -1, col="red", lty = "dashed") + 
  #theme(text = element_text(size=12), axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) +
  #theme(legend.position="top") +
  xlab("Mean naturalness rating \n in explicit ignorance context") +
  ylab("Mean certainty rating \n (from Degen & Tonhauser 2022)") 
  #theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) 
ggsave("../graphs/mean-acceptability-against-mean-certainty.pdf",height=5,width=5)

# calculate Spearman rank correlation
corr <- cor.test(x=data$Mean, y=data$MeanCertain, method = 'spearman', exact = FALSE)
corr


  