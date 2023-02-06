####################################################################################################
# R code for the registered report study accepted to Neuroimage:
# "Characterizing habit learning in the human brain at the individual and group levels: a multi-modal MRI study"
# adopted form the code made by Eva Pool (from the work by Pool et al., 2022) 
## Last modified by Rani on January 2023
## These analyses are based on the files produced in matlab by analysis_behavior_HIS.m
####################################################################################################
# ----------------------------------------- PRELIMINARY STUFF ---------------------------------------------------------------------------

rm(list=ls())

# load libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(flexmix, plotrix, scales, rstudioapi,effectsize, car, lme4, lmerTest, pbkrtest, ggplot2, dplyr, plyr, tidyr, multcomp, mvoutlier, HH, doBy, psych, pastecs, reshape, reshape2,
               jtools, effects, compute.es, DescTools, MBESS, afex, ez, metafor, influence.ME, GPArotation, SparkR, emmeans, afex, ntile, ggpubr,lattice)

# Set path
home_path <- dirname(getActiveDocumentContext()$path)
data_base_file <- file.path(home_path,'my_databases/txt_data/presses_HIS_May_2022.csv')
ratings_data <- file.path(home_path,'my_databases/txt_data/food_liking_HIS_May_2022.txt')
figures_path    <- file.path(home_path,'figures')
clustered_data_file <- file.path(home_path,'my_databases/txt_data/clustered_subgroups_HIS_May_2022.csv')
setwd (home_path)

# get database
FULL <- read.csv(data_base_file, header=TRUE, sep=",")
RATINGS=read.delim(ratings_data, header = TRUE, sep = "\t")

# remove the baseline condition from the data
FULL <- subset(FULL, VALUE == 'valued' | VALUE == 'devalued')

# define factors
FULL$ID        <- factor(FULL$ID)
FULL$GROUP     <- factor(FULL$GROUP)
FULL$VALUE     <- factor(FULL$VALUE)

RATINGS$ID     <- factor(RATINGS$ID)
RATINGS$group  <- factor(RATINGS$group)
RATINGS$value  <- factor(RATINGS$value)
RATINGS$time   <- factor(RATINGS$time)

# ----------------------------------------- EFFECTS OF OVER-TRAINING ON DEVALUATION SENSITIVITY -----------------------------------------
############################################### Manipulation check
# getting variables ready:
RATINGS.regular = subset(RATINGS, time != "afterExperiment")
RATINGS.regular.hunger = subset(RATINGS.regular, value == "hunger")
RATINGS.regular.liking = subset(RATINGS.regular, value != "hunger")

# ----- liking ratings
summary(liking <- aov_car(liking ~ value*time + Error (ID/value*time), data = RATINGS.regular.liking)) # MAIN
omega_squared(liking)
mean_liking = ddply(RATINGS.regular.liking,.(value,time),summarise, avg_liking=mean(liking)) # means
ddply(mean_liking, .(value), summarise, change=diff(avg_liking)) # reduction
ggline(RATINGS.regular.liking, x = "time", y = "liking", group = "value", color = "value", add = c("mean_se", "jitter"), order = c("pre", "post")) # plot

# exploratory:
summary(liking <- aov_car(liking ~ group*value*time + Error (ID/value*time), data = RATINGS.regular.liking)) # exploratory (with groups)
omega_squared(liking)

# ------ hunger
t.test(RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "pre"], RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "post"], paired = TRUE, alternative = "two.sided") # MAIN
ddply(RATINGS.regular.hunger,.(time),summarise, avg_liking=mean(liking)) # means
ggline(RATINGS.regular.hunger, x = "time", y = "liking", group = "ID", add = c("mean_se"), order = c("pre", "post"), ylab = "hunger") # plot

# exploratory: for SUPP
summary(hunger <- aov_car(liking ~ group*time + Error (ID/time), data = RATINGS.regular.hunger)) # exploratory (anova with groups)
omega_squared(hunger)
t.test(RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "pre" & RATINGS.regular.hunger$group == 1], RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "pre"& RATINGS.regular.hunger$group == 3], paired = FALSE, alternative = "two.sided") # MAIN
t.test(RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "post" & RATINGS.regular.hunger$group == 1], RATINGS.regular.hunger$liking[RATINGS.regular.hunger$time == "post"& RATINGS.regular.hunger$group == 3], paired = FALSE, alternative = "two.sided") # MAIN

ggline(RATINGS.regular.hunger, x = "time", y = "liking", color = "group", add = c("mean_se","jitter"), order = c("pre", "post"), ylab = "Hunger", xlab = "Time relative to devaluation") # plot


#----------------------------- Manipulation checks FIGURE 5-------------------------

RATINGS.regular.liking$time   <- dplyr::recode(RATINGS.regular.liking$time, "pre" = "Before", "post" = "After")
RATINGS.regular.hunger$time   <- dplyr::recode(RATINGS.regular.hunger$time, "pre" = "Before", "post" = "After")
RATINGS.regular.liking$value   <- dplyr::recode(RATINGS.regular.liking$value, "deval" = "Devalued outcome", "val" = "Valued outcome" )
RATINGS.regular.liking$value = relevel(RATINGS.regular.liking$value, "Valued outcome")
# To include the post experiment measure use this
#RATINGS.regular.hunger = subset(RATINGS, value == "hunger")
#RATINGS.regular.liking = subset(RATINGS, value != "hunger")
#RATINGS.regular.liking$time   <- dplyr::recode(RATINGS.regular.liking$time, "pre" = "Before", "post" = "After", "afterExperiment" = "Post experiment")
#RATINGS.regular.hunger$time   <- dplyr::recode(RATINGS.regular.hunger$time, "pre" = "Before", "post" = "After", "afterExperiment" = "Post experiment")


p <- ggplot(RATINGS.regular.liking, aes(x = factor(time, level = c("Before","After")), y = liking, fill = value, color = value)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .5, jitter.height = 0)) +
  geom_line(data = RATINGS.regular.liking, aes(group = ID, y = liking, color = value), alpha = .2, size = 0.3) +
  geom_boxplot(alpha=0.3,outlier.alpha =0) +
  scale_y_continuous(breaks = seq(-5, 5, len = 11)) +
  ylab('Liking ratings')+
  xlab('Devaluation')+
  facet_grid(cols=vars(value))+
  scale_fill_manual(values=c("slateblue", "darkorange3")) + scale_color_manual(values=c("slateblue", "darkorange3"))

pp <- p + theme_classic(base_size = 14, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 12, face = "bold"),
        strip.text.y = element_text(size = 12, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        #panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="gray", size=0.2),
        axis.title.y = element_text(size = 14, face = "bold"))

p2 <- ggplot(RATINGS.regular.hunger, aes(x = factor(time, level = c("Before","After")), y = liking, fill = value, color = value)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .5, jitter.height = 0)) +
  geom_line(data = RATINGS.regular.hunger, aes(group = ID, y = liking, color = value), alpha = .2, size = 0.3) +
  geom_boxplot(alpha=0.3,outlier.alpha =0) +
  scale_y_continuous(breaks = seq(0, 10, len = 11)) +
  ylab('Hunger Ratings')+
  xlab('Devaluation')+
  #scale_y_continuous(position = "right")+
  facet_grid(cols=vars(value))+
  scale_fill_manual(values=c("gray8")) + scale_color_manual(values=c("gray8"))

pp2 <- p2 + theme_classic(base_size = 14, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 12, face = "bold", color = "white"),
        strip.text.y = element_text(size = 12, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="gray", size=0.2),
        axis.title.y = element_text(size = 14, face = "bold"))

comb <- grid.arrange(pp, pp2, nrow = 1, layout_matrix = rbind(c(1,1,1,1,1,1,1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2)))

ggsave(file.path(figures_path,'ManipulationCheck.tiff'), comb, dpi = 100)


############################################### Main behavioral analysis (outcome devaluation induced changes)

# ----- MAIN:
summary(main <- aov_car(presses_change ~ GROUP*VALUE + Error (ID/VALUE), data = FULL))
omega_squared(main)
ggline(FULL, x = "VALUE", y = "presses_change", color = "GROUP", add = c("mean_sd", "jitter"), order = c("valued", "devalued")) # plot

#----------------------------- FIGURE 4 Main behavioral results  -------------------------
BASIC = FULL[,c('ID', 'GROUP', 'VALUE', 'presses_pre','presses_post')]
colnames(BASIC) <- c('ID','GROUP', 'VALUE', 'Before','After')
# to include reacquisition:
#BASIC = FULL[,c('ID', 'GROUP', 'VALUE', 'presses_pre','presses_post','presses_reacquisition')]
#colnames(BASIC) <- c('ID','GROUP', 'VALUE', 'Before','After','Reacquisition')
BASIC = BASIC %>% gather(time, mean_presses, -c(ID, GROUP, VALUE))
BASIC = BASIC[order(BASIC$ID, BASIC$GROUP),]
BASIC$time = as.factor(BASIC$time)

BASIC$VALUE   <- dplyr::recode(BASIC$VALUE, "devalued" = "Devalued", "valued" = "Valued" )
BASIC$GROUP  <- dplyr::recode(BASIC$GROUP, "1" = "Short training", "3" = "Extensive training" )
BASIC$VALUE = relevel(BASIC$VALUE, "Valued")
BASIC$time = relevel(BASIC$time, "Before")

# For boxplots use this:
# p <-  ggplot(BASIC, aes(x = interaction(VALUE,time), y = mean_presses, fill=VALUE, color = VALUE)) +
#  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .5, jitter.height = 0)) +
#  geom_line(data = BASIC, aes(group = interaction(ID,time), y = mean_presses, color = VALUE), alpha = .4, size = 0.4, color='gray') +
#  geom_boxplot(alpha=0.3,outlier.alpha = 0, position="dodge2") +
#  stat_summary(fun=mean, geom='point', shape=5, size=2, color="black", fill="white") +
#  scale_y_continuous(breaks= pretty_breaks()) +
#  ylab('Responses / sec')+
#  xlab('Devaluation') +
#  facet_grid(.~GROUP) +
#  scale_x_discrete(drop = FALSE, labels=c("Valued.Before" = "", "Devalued.Before" = "Before", "Valued.After" = "", "Devalued.After" = "After"))+
#  scale_fill_manual(values=c("slateblue", "darkorange3")) + scale_color_manual(values=c("slateblue", "darkorange3"))

p <- ggplot(BASIC, aes(x = interaction(VALUE,time), y = mean_presses, fill=VALUE, color = VALUE)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .5, jitter.height = 0)) +
  geom_line(data = BASIC, aes(group = interaction(ID,time), y = mean_presses, color = VALUE), alpha = .2, size = 0.3, color='gray') +
  geom_bar(alpha=0.1, stat = "summary", fun = "mean") +
  stat_summary(fun.data = mean_se, geom = "errorbar", width=.2) +
  scale_y_continuous(breaks= pretty_breaks()) +
  ylab('Responses / sec')+
  xlab('Devaluation') +
  facet_grid(.~GROUP) +
  scale_x_discrete(drop = FALSE, labels=c("Valued.Before" = "", "Devalued.Before" = "Before", "Valued.After" = "", "Devalued.After" = "After"))+
  scale_fill_manual(values=c("slateblue", "darkorange3")) + scale_color_manual(values=c("slateblue", "darkorange3"))

pp <- p + theme_light(base_size = 14, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 16, face = "bold"),
        strip.text.y = element_text(size = 16, face = "bold"),
        strip.text = element_text(colour = 'black'),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        axis.text.x = element_text(hjust=1.2, face="bold", size=14),
        axis.ticks.x = element_blank(),
        legend.box.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="gray", size=0.05),
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"))

pp$labels$fill <- "Outcome type"
pp$labels$colour <- "Outcome type"

# For boxplots use this:
#ggsave(file.path(figures_path,'MainBehavioral.tiff'), pp, dpi = 100)
ggsave(file.path(figures_path,'MainBehavioral_Bar.tiff'), pp, dpi = 100)


# ----------------------------------------- END OF REGISTERED (non-exploratory) ANALYSIS -----------------------------------------
#---------------------------- ADDED AFTER A REVIEW 
########################## Reacquisition exploratory behavioral analysis (outcome devaluation induced changes)

# ----- MAIN:
FULL_ra=FULL
FULL_ra$ra_min_post = FULL_ra$presses_reacquisition - FULL_ra$presses_post

summary(main_ra <- aov_car(ra_min_post ~ GROUP*VALUE + Error (ID/VALUE), data = FULL_ra))
omega_squared(main_ra)

#----------------------------- FIGURE S1 Main behavioral results  -------------------------
BASIC = FULL_ra[,c('ID', 'GROUP', 'VALUE', 'presses_post', 'presses_reacquisition')]
colnames(BASIC) <- c('ID','GROUP', 'VALUE', 'Extinction','Reacquisition')
BASIC = BASIC %>% gather(time, mean_presses, -c(ID, GROUP, VALUE))
BASIC = BASIC[order(BASIC$ID, BASIC$GROUP),]
BASIC$time = as.factor(BASIC$time)

BASIC$VALUE   <- dplyr::recode(BASIC$VALUE, "devalued" = "Devalued", "valued" = "Valued" )
BASIC$GROUP  <- dplyr::recode(BASIC$GROUP, "1" = "Short training", "3" = "Extensive training" )
BASIC$VALUE = relevel(BASIC$VALUE, "Valued")

p <- ggplot(BASIC, aes(x = interaction(VALUE,time), y = mean_presses, fill=VALUE, color = VALUE)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .5, jitter.height = 0)) +
  geom_line(data = BASIC, aes(group = interaction(ID,time), y = mean_presses, color = VALUE), alpha = .2, size = 0.3, color='gray') +
  geom_bar(alpha=0.1, stat = "summary", fun = "mean") +
  stat_summary(fun.data = mean_se, geom = "errorbar", width=.2) +
  scale_y_continuous(breaks= pretty_breaks()) +
  ylab('Responses / sec')+
  xlab('Test') +
  facet_grid(.~GROUP) +
  scale_x_discrete(drop = FALSE, labels=c("Valued.Extinction" = "", "Devalued.Extinction" = "Extinction", "Valued.Reacquisition" = "", "Devalued.Reacquisition" = "Reacquisition"))+
  scale_fill_manual(values=c("slateblue", "darkorange3")) + scale_color_manual(values=c("slateblue", "darkorange3"))

pp <- p + theme_light(base_size = 14, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 16, face = "bold"),
        strip.text.y = element_text(size = 16, face = "bold"),
        strip.text = element_text(colour = 'black'),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        axis.text.x = element_text(hjust=1, face="bold", size=14),
        axis.ticks.x = element_blank(),
        legend.box.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="gray", size=0.05),
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"))

pp$labels$fill <- "Outcome type"
pp$labels$colour <- "Outcome type"

pp

ggsave(file.path(figures_path,'ReacquisitionBehavioral_Bar.tiff'), pp, dpi = 100)


########################## Reacquisition exploratory behavioral analysis (outcome devaluation induced changes)

## Exploratory Kolmogorov-Smirnov test of the habit index

habitIndex_data = ddply(FULL,.(ID,GROUP),summarise,habit_index=mean(habit_index))
shortHabitIndex = habitIndex_data[habitIndex_data$GROUP==1,]$habit_index
longHabitIndex = habitIndex_data[habitIndex_data$GROUP==3,]$habit_index

ks.test(shortHabitIndex, longHabitIndex)


########################## Testing effect of response rate throughout the task (which maybe represent motivation and aligned with response-outcome experienced contingency)

training_and_habitIndex_data = ddply(FULL,.(ID,GROUP),summarise,habit_index=mean(habit_index), trainingPressingRate=mean(trainingPressingRate), trainingPressingRateExcludingLastRun=mean(trainingPressingRateExcludingLastRun))
cor.test(training_and_habitIndex_data$trainingPressingRate, training_and_habitIndex_data$habit_index, method = "pearson")
cor.test(training_and_habitIndex_data$trainingPressingRate, training_and_habitIndex_data$habit_index, method = "spearman")
cor.test(training_and_habitIndex_data$trainingPressingRateExcludingLastRun, training_and_habitIndex_data$habit_index, method = "pearson")
cor.test(training_and_habitIndex_data$trainingPressingRateExcludingLastRun, training_and_habitIndex_data$habit_index, method = "spearman")

# regression test
FULL_pressInTrainging = FULL
FULL_pressInTrainging$trainingPressingRate = scale(FULL_pressInTrainging$trainingPressingRate)
FULL_pressInTrainging$trainingPressingRateExcludingLastRun = scale(FULL_pressInTrainging$trainingPressingRateExcludingLastRun)
summary(main <- lm(habit_index ~ GROUP*trainingPressingRate, data = FULL_pressInTrainging))
summary(main <- lm(habit_index ~ GROUP*trainingPressingRateExcludingLastRun, data = FULL_pressInTrainging))

#---------------------------- END OF ADDED AFTER A REVIEW (but see another section in the clustering part)

###############################################  Some additional analyses:
fractal_data <- file.path(home_path,'my_databases/txt_data/fractal_ratings_HIS_May_2020.txt')
FRACTALS=read.delim(fractal_data, header = TRUE, sep = "\t")

# define factors
FRACTALS$ID        <- factor(FRACTALS$ID)
FRACTALS$group     <- factor(FRACTALS$group)
FRACTALS$value     <- factor(FRACTALS$value)

# ----- contingency awareness test
t.test(FRACTALS$contingency[FRACTALS$value == "val" | FRACTALS$value == "deval"]) # for val and deval; (one sample t-test against 0) ; expected: significant
t.test(FRACTALS$contingency[FRACTALS$value == "baseline"]) # for baseline ; (one sample t-test against 0) ; expected: non-significant
# test for group difference and interaction:
summary(aov(contingency ~ group*value + Error (ID/value), data = subset(FRACTALS, value != "baseline"))) # expected nothing significant.

# ----- fractal liking test (rated following devaluation)
t.test(FRACTALS$liking[FRACTALS$value == "val"], FRACTALS$liking[FRACTALS$value == "deval"], paired = TRUE, alternative = "two.sided") # paired
# test for group difference and interaction:
summary(aov(liking ~ group*value + Error (ID/value), data = subset(FRACTALS, value != "baseline"))) # expected non-significant group and interaction effects.

# ----------------------------------------- END OF NON-REGISTERED OF ALL ANALYSES -----------------------------------------

#------------------------------------------------------------------------------
#--------------------------- Organize subjects in sub-groups: -----------------
#------------------------------------------------------------------------------
short = FULL[FULL$GROUP==1,]
long = FULL[FULL$GROUP==3,]

# Some adjustments before clustering:
#---------------------------------------
# (1) --------- Removing extremely unengaged subjects (less than 3 SDs from their group mean)
short[short$presses_pre < mean(short$presses_pre)-(3*sd(short$presses_pre)),]
long[long$presses_pre < mean(long$presses_pre)-(3*sd(long$presses_pre)),]
# Not engaged: 248, 268, 275
toRemove = c(
  as.numeric(paste(short[short$presses_pre < mean(short$presses_pre)-(3*sd(short$presses_pre)),]$ID)) %>% unique,
  as.numeric(paste(long[long$presses_pre < mean(long$presses_pre)-(3*sd(long$presses_pre)),]$ID)) %>% unique)
FULL_adjusted = FULL[!(FULL$ID %in% toRemove),]

# (2) --------- Change interpretation for those with extremely large reduction (>90%) for both conditions to be goal-directed:
extremes=as.numeric(paste(FULL[FULL$presses_post < FULL$presses_pre*0.1,]$ID))
counts = count(extremes)
# Measure most likely reflects the opposite:
# 154 221 280
toChange = counts[counts$freq == 2,]$x
# the adjustment is done by mean(pre) - mean(post), each mean calculated for on valued and devalued
for (subj in toChange) {
  FULL_adjusted[FULL_adjusted$ID==subj,]$habit_index = mean(FULL_adjusted[FULL_adjusted$ID==subj,]$presses_pre) - mean(FULL_adjusted[FULL_adjusted$ID==subj,]$presses_post)
  print(FULL_adjusted[FULL_adjusted$ID==subj,])
}

# NOW RUN FLEXMIX TO IDENTIFY CLUSTERS:
#---------------------------------------
temp_for_clustering = ddply(FULL_adjusted,.(ID,GROUP),summarise,habit_index=mean(habit_index))

clustering_data =data.frame(temp_for_clustering$habit_index)
clustering_data$group = as.numeric(paste(temp_for_clustering$GROUP))
clustering_data$group[clustering_data$group == 1] <- '1-Day'
clustering_data$group[clustering_data$group == 3] <- '3-Day'
clustering_data$group = factor(clustering_data$group)
clustering_data$typeMeasure <- 'changeBehavior'
colnames(clustering_data) [1] <- "habit_score" # NOT ACTUALLY NORMED...
clustering_data = cbind(ID=as.numeric(paste(temp_for_clustering$ID)),clustering_data)
clustering_data$ID = factor(clustering_data$ID)

#  test what is the number of clusters that best explains the data:
n_clusters <- stepFlexmix(habit_score ~ group, data = clustering_data, control = list(verbose = 0), k = 1:5, nrep = 200)
n_clusters
getModel(n_clusters, "BIC") # see which model fits best

# Repeat the analysis specifying the number of cluster we found best:
set.seed(5)
clustered <- flexmix(habit_score ~ group, data = clustering_data, k = 2)
clustered
print(table(clusters(clustered), clustering_data$group))
clustering_data$Cluster = factor(clusters(clustered)) # create a variable based on the clustering

#--------------------------- FIGURE X Cluster analysis  ------------------------
# rename variables for plot
clustering_data$group     <- dplyr::recode(clustering_data$group, "1-Day" = "Short training", "3-Day" = "Extensive training" )
clustering_data$Cluster   <- dplyr::recode(clustering_data$Cluster, "1" = "Goal-directed", "2" = "Habitual" )

dat_text <- data.frame(label = c("Short training", "Extensive training"),
                       group = c("Short training", "Extensive training"),
                       x= c(3.4, 3.84),  y = c(Inf, Inf))

p <-  ggplot(clustering_data, aes(habit_score, fill = Cluster)) +
  geom_histogram(aes(y=..density..),alpha=0.2,binwidth=0.3)+
  geom_density(alpha = 0.5)+
  xlab('Habit index')+
  ylab('Density')+
  facet_wrap(group~.,ncol=1)+
  geom_text(data=dat_text, mapping = aes(x=x, y=y, label=label), inherit.aes=FALSE, vjust = "inward", hjust = "inward", check_overlap = TRUE, size=5.1 , fontface = "bold") +
  scale_fill_manual(values=c("turquoise4", "coral3")) +
  theme_bw()

pp <- p + theme_classic(base_size = 11, base_family = "Helvetica")+
  theme(
    strip.background = element_blank(),
    strip.text = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    panel.grid.major = element_line(color="gray", size=0.1),
    legend.position = c(0.85, 0.85),
    legend.background = element_rect(fill = "white", color = "gray"),
    aspect.ratio=0.8
  )
pp$labels$fill <- "Subgroup"

ggsave(file.path(figures_path,'Cluster_analysis.tiff'), pp, dpi = 100, height = 605, width=416, units = "px")

# (3) --------- REMOVING extreme "IRRATIONALE" BEHAVIOR (that became part of the goal-directed cluster)
# first check:
clustering_data[clustering_data$Cluster == 'Habitual',]$habit_score %>% max
clustering_data[clustering_data$Cluster == 'Habitual',]$habit_score %>% min
# make sure there is no one on the middle:
clustering_data[clustering_data$Cluster=='Goal-directed' & clustering_data$habit_score>-0.55 & clustering_data$habit_score<0.5,]$habit_score
# irrational:
clustering_data[clustering_data$Cluster=='Goal-directed' & clustering_data$habit_score < min(clustering_data[clustering_data$Cluster == 'Habitual',]$habit_score),]
#Remove them:
clustering_data = clustering_data[!(clustering_data$Cluster=='Goal-directed' & clustering_data$habit_score < min(clustering_data[clustering_data$Cluster == 'Habitual',]$habit_score)),]


table(clustering_data$Cluster, clustering_data$group)
write.csv(clustering_data, file=clustered_data_file, row.names = FALSE)

# copy the file to the server relevant folder (for the MRI-related analyses):
system(paste('rsync -a --progress', paste("'",clustered_data_file,"'", sep=""), 'shirangera@boost.tau.ac.il:/export2/DATA/HIS/HIS_server/analysis/behavior_analysis_output/my_databases/txt_data'))


#---------------------------- ADDED AFTER A REVIEW 
##### Explore  effects of response rate throughout the task (which maybe represent motivation and aligned with response-outcome experienced contingency)

# add trainingPressingRate data
clustering_data$trainingPressingRate = 0
clustering_data$trainingPressingRateExcludingLastRun = 0
for (sub in clustering_data$ID) {
  clustering_data[clustering_data$ID==sub,]$trainingPressingRate = FULL[FULL$ID==sub,]$trainingPressingRate[1]
  clustering_data[clustering_data$ID==sub,]$trainingPressingRateExcludingLastRun = FULL[FULL$ID==sub,]$trainingPressingRateExcludingLastRun[1]
}

# test (anova)
summary(main <- aov(trainingPressingRate ~ group*Cluster, data = clustering_data))
omega_squared(main)

summary(main <- aov(trainingPressingRateExcludingLastRun ~ group*Cluster, data = clustering_data))
omega_squared(main)
#---------------------------- END OF ADDED AFTER A REVIEW (but see another section in the clustering part)

# ____________________________________________ ADDITIONS ___________________________________________
# ____________________________________________ ADDITIONS ___________________________________________
# ____________________________________________ ADDITIONS ___________________________________________

#--------------------------- FLEXMIX TO IDENTIFY CLUSTERS - TRY ON EACH group SEPERATELY -----------------

#  what is the number of clusters that better explains the data
short=clustering_data[clustering_data$group=="Short training",]
long=clustering_data[clustering_data$group=="Extensive training",]
n_clusters <- stepFlexmix(habit_score ~ 1, data = short, control = list(verbose = 0), k = 1:5, nrep = 200)
getModel(n_clusters, "BIC")

n_clusters <- stepFlexmix(habit_score ~ 1, data = long, control = list(verbose = 0), k = 1:5, nrep = 200)
getModel(n_clusters, "BIC")

# get cluster size
getModel(n_clusters, which = 1)
getModel(n_clusters, which = 2)
getModel(n_clusters, which = 3)
getModel(n_clusters, which = 4)
getModel(n_clusters, which = 5)
BIC(n_clusters)

# the we do the analysis specifying the number of cluster we found with step flex
mixlm <- flexmix(habit_score ~ group, data = clustering_data, k = 2)
mixlm
print(table(clusters(mixlm), clustering_data$group))
clustering_data$Cluster = factor(clusters(mixlm)) # create a variable based on the clustering

