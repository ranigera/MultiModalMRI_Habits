####################################################################################################
# HIS study - exploratory questionnaire analysis (oriented at examining Stress affect following Pool et al. (2022)                                                                                           #
# Code adapted from Pool et al. (2022) - originally written by Eva pool and now adjusted by Rani Gera
####################################################################################################

rm(list=ls())

# load libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(car,afex,doBy,lme4,lmerTest,ggplot2,ggExtra,BayesFactor,sjstats,jtools,plyr,dplyr,tidyr
               ,metafor,rmcorr,flexmix,psych,emmeans,devtools,effectsize,GPArotation)

#---------------------------------------------------------------------------
#                    PRELIMINARY STUFF 
#---------------------------------------------------------------------------
data_base_file <- '../1_behaviorAnalysis/my_databases/txt_data/presses_HIS_May_2022.csv'
output_questionnaire_scores_file  = 'HIS_QUESTIONNARE_SCORES.csv';
output_questionnaire_scores_subgroups_file  = 'HIS_QUESTIONNARE_SCORES_w_subgroups_scores.csv';
figures_path = 'Figs/'
#get data
output_questionnaire_scores = read.csv(output_questionnaire_scores_file)
FULL <- read.csv(data_base_file, header=TRUE, sep=",")
# remove the baseline condition from the data
FULL <- subset(FULL, VALUE == 'valued' | VALUE == 'devalued')
# define factors
FULL$ID        <- factor(FULL$ID)
FULL$GROUP     <- factor(FULL$GROUP)
FULL$VALUE     <- factor(FULL$VALUE)

# NORMALIZE:
FULL$norm_presses_change     <- scale(FULL$presses_change)

# subscales we wont use (BIS)
output_questionnaire_scores$BIS_total       <- scale(output_questionnaire_scores$BIS_total)
output_questionnaire_scores$BIS_attentional <- scale(output_questionnaire_scores$BIS_attentional)
output_questionnaire_scores$BIS_motor       <- scale(output_questionnaire_scores$BIS_motor)
output_questionnaire_scores$BIS_nonplanning <- scale(output_questionnaire_scores$BIS_nonplanning)
# subscales we wont use (TICS)
output_questionnaire_scores$TICS_CSSS      <- scale(output_questionnaire_scores$TICS_CSSS)
output_questionnaire_scores$TICS_WOOV      <- scale(output_questionnaire_scores$TICS_WOOV)
output_questionnaire_scores$TICS_SOOV      <- scale(output_questionnaire_scores$TICS_SOOV)
output_questionnaire_scores$TICS_PREPE     <- scale(output_questionnaire_scores$TICS_PREPE)
output_questionnaire_scores$TICS_WODI      <- scale(output_questionnaire_scores$TICS_WODI)
output_questionnaire_scores$TICS_EXWO      <- scale(output_questionnaire_scores$TICS_EXWO)
output_questionnaire_scores$TICS_LACK      <- scale(output_questionnaire_scores$TICS_LACK)
output_questionnaire_scores$TICS_SOTE      <- scale(output_questionnaire_scores$TICS_SOTE)
output_questionnaire_scores$TICS_SOIS      <- scale(output_questionnaire_scores$TICS_SOIS)
output_questionnaire_scores$TICS_WORY      <- scale(output_questionnaire_scores$TICS_WORY)
# Combined Stai:
output_questionnaire_scores[,'STAI_comb'] = rowMeans(output_questionnaire_scores[,c('STAIS_total', 'STAIT_total')])
# subscales we wont use (STAI)
output_questionnaire_scores$STAIS_total         <- scale(output_questionnaire_scores$STAIS_total)
output_questionnaire_scores$STAIT_total         <- scale(output_questionnaire_scores$STAIT_total)
output_questionnaire_scores$STAI_comb           <- scale(output_questionnaire_scores$STAI_comb)

#----------------------------  DATA REDUCTION  ----------------------------------

# prepare database for the FA
Q_EFA.means = output_questionnaire_scores[,c('TICS_SOOV', 'TICS_PREPE', 'TICS_WODI', 'TICS_EXWO', 'TICS_LACK', 'TICS_SOTE', 'TICS_SOIS', 'TICS_WORY', 'TICS_WOOV', 'BIS_motor', 'BIS_attentional', 'BIS_nonplanning','STAI_comb')]

# quick look at the covarivance structure
r.subscale = cor(Q_EFA.means, use = "pairwise.complete.obs")
cor.plot(Q_EFA.means,numbers=TRUE,main="correlation matrix")

# check distributions before proceeding with FA
describe (Q_EFA.means)
pairs.panels(na.omit(Q_EFA.means))

# determine the number of factors
nFactor  <- fa.parallel(Q_EFA.means, fm = "ml")


# apply EFA with oblimin
quest.1.efa <- fa(r = Q_EFA.means, nfactors = 3, rotate = "oblimin", fm = "ml") # in Pool et al. it was 4 factors... the interesting factors had the same compinenets exactly

print(quest.1.efa$loadings,cutoff = 0.0)

# create figure with EFA solution
fa.diagram(quest.1.efa)

# save the plot in the figures folder
#dev.print(pdf, file.path(figures_path,'Figure_EFA_oblimin.pdf'))
#dev.off()

# calculate the factors loadings
s = factor.scores (Q_EFA.means, quest.1.efa) # 
s

#---------------------------- USE FACTOR AS AS MODERATOR IN THE MAIN ANALYSIS ----------

# merge with the FULL database
output_questionnaire_scores_withEFA = cbind(output_questionnaire_scores,s$scores)

# combine it with the participants ID
EFA_CHANGE <- join(FULL,output_questionnaire_scores_withEFA, type = "full")
#EFA_CHANGE <- join (CHANGE,dat, type = "full")

# run full model for each factor individually
# stress affect
summary(inter.affect <- lmer(norm_presses_change ~ GROUP*VALUE*ML1 + (1|ID), data = EFA_CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
summary(no_inter.affect <- lmer(norm_presses_change ~ GROUP*VALUE + GROUP*ML1 + VALUE*ML1 + (1|ID), data = EFA_CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
anova(inter.affect,no_inter.affect)
Confint(inter.affect, level = 0.95) 

# ----- assumptions check
plot(fitted(inter.affect),residuals(inter.affect)) 
qqnorm(residuals(inter.affect))
hist(residuals(inter.affect))
# *** NOTHING WAS FOUN D TO ANY OF THE OTHER FACTORS, REGARDLESS OF THE METHO I USED (STAI-T, STAI-S OR STAI-COMBINED)

# test and different points of the model to understand interaction
# Stress affective -1 SD people low on affectiv stress have effect of overtraining
EFA_CHANGE$AFF_pSD <- scale(EFA_CHANGE$ML1, scale = T) + 1 # here I'm going to test at - 1SD (so people that are low in anxiety)
summary(sslop.pSD <- lmer(norm_presses_change ~ GROUP*VALUE*AFF_pSD + (1 |ID), data = EFA_CHANGE, REML=FALSE,control = lmerControl(optimizer ="bobyqa")))
Confint(sslop.pSD, level = 0.95) 

# Stress Affective +1 SD people high on affective stress have effect of overtraining
EFA_CHANGE$AFF_mSD <- scale(EFA_CHANGE$ML1, scale = T) - 1 # here I'm going to test at + 1SD (so people that are high in anxiety)
summary(sslop.mSD <- lmer(norm_presses_change ~ GROUP*VALUE*AFF_mSD + (1 |ID), data = EFA_CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
Confint(sslop.mSD, level = 0.95) 

#---------------------------- FIGURES ---------------------------

# this tests the model predictions as we do in lmer but does not allow to display distributions
AFF.means <- aggregate(EFA_CHANGE$habit_index, by = list(EFA_CHANGE$ID, EFA_CHANGE$GROUP, EFA_CHANGE$AFF_pSD, EFA_CHANGE$AFF_mSD, EFA_CHANGE$ML1), FUN='mean', na.rm = T) # extract means
colnames(AFF.means) <- c('ID','GROUP', 'AFF_pSD', 'AFF_mSD','AFF', 'habit_index')
AFF.means = AFF.means[order(AFF.means$ID),]
AFF.means$habit_index = scale(AFF.means$habit_index)
# to assess to imapct of the extream let's run a robust analysis
# AFF.means$normChangeBehav <- rank(AFF.means$normChangeBehav)


# ADJUSTED MEANS in case we want see the estimations from the model
acqC1.aov      <- aov_car(habit_index  ~ GROUP*AFF +Error(ID), data = AFF.means, observed = c("AFF"), factorize = F, anova_table = list(es = "pes"))
acqC1.adjmeans <- emmeans(acqC1.aov, specs = c("GROUP"), by = "AFF", at = list(AFF= c(-1, 1)))
acqC1.adjmeans

acqC1.low.aov      <- aov_car(habit_index  ~ GROUP*AFF_pSD +Error(ID), data = AFF.means, observed = c("AFF"), factorize = F, anova_table = list(es = "pes"))
acqC1.high.aov     <- aov_car(habit_index  ~ GROUP*AFF_mSD +Error(ID), data = AFF.means, observed = c("AFF"), factorize = F, anova_table = list(es = "pes"))

AFF.means$GROUP           <- dplyr::recode(AFF.means$GROUP, "1" = "Short", "3" = "Extensive" )

pp <- ggplot(AFF.means, aes(x = AFF, y = habit_index, fill = GROUP, color = GROUP)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .0, jitter.height = 0)) +
  geom_smooth(method = lm, level = .95, alpha = .1, fullrange=TRUE) +
  ylab('Habit index')+
  xlab('Stress Affect')+
  annotate("rect", xmin=0.95, xmax=1.05, ymin=min(AFF.means$habit_index), ymax=max(AFF.means$habit_index), alpha=0.3, fill="gray") +
  annotate("rect", xmin=-0.95, xmax=-1.05, ymin=min(AFF.means$habit_index), ymax=max(AFF.means$habit_index), alpha=0.3, fill="gray") +
  scale_fill_manual(values=c("#56B4E9", "#0F2080")) +
  scale_color_manual(values=c("#56B4E9", "#092C48")) +
  scale_x_continuous(breaks=seq(-2.5,2.5,0.5)) +
  theme_bw()

theme_continous_plot <- theme_bw(base_size = 18, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 18, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title.x = element_text(size = 22),
        axis.text = element_text(size = 10),
        axis.title.y = element_text(size = 22))

ppp <- pp + theme_continous_plot


pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1), legend.background = element_rect(color = "white")), 
                  type = "density", groupFill = T, color = NA, alpha = .2)

pdf(file.path(figures_path,'Figure_stressAffect_pannelA.pdf'))
print(pppp)
dev.off()

adj_meanCR  <- summary(acqC1.adjmeans)$emmean
adj_lowerCL <- summary(acqC1.adjmeans)$lower.CL
adj_upperCL <- summary(acqC1.adjmeans)$upper.CL

adj_group   <- c("Short", "Extensive", "Short", "Extensive")
adj_SD      <- c("Lower Stress Affect (-1 SD)", "Lower Stress Affect (-1 SD)", "Higher Stress Affect (+1 SD)", "Higher Stress Affect (+1 SD)")
adj_means   <- data.frame(adj_meanCR, adj_lowerCL, adj_upperCL, adj_group, adj_SD)

adjmeans_plot <- ggplot(data = adj_means, aes(x = factor(adj_group, levels = c("Short","Extensive")), y = adj_meanCR, 
                                              color = adj_group,
                                              fill = adj_group)) + 
  geom_crossbar(aes(y = adj_meanCR, ymin =adj_lowerCL, ymax = adj_upperCL), width = 0.85 , alpha = 0.1) +
  facet_grid(~ factor(adj_SD, levels = c("Lower Stress Affect (-1 SD)","Higher Stress Affect (+1 SD)"))) +
  ylab('Habit index')+
  xlab('Training duration')+
  ylim(min= -1.5, max = 3)+
  scale_fill_manual(values=c("#0F2080","#56B4E9" )) +
  scale_color_manual(values=c( "#092C48","#56B4E9")) +
  theme_bw()


theme_means_plots <- theme_bw(base_size = 18, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 16, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22))

ppp <- adjmeans_plot+ theme_means_plots 


pdf(file.path(figures_path,'Figure_stressAffect_pannelB.pdf'))
print(ppp)
dev.off()



#-----------------------------------------------------------------------------
# NON-EFA SUPPLEMENTARY: SEPARATE TESTS FOR ANXIETY AND WORRIES
#-----------------------------------------------------------------------------

# we conclude by intpreting our results in terms of anxiety and chronic worries 
# let make sure that is not an artifact of the EFA 
CHANGE=EFA_CHANGE
# -------------------- ANXIETY ----------------------------------------
summary(inter.anxiety <- lmer(norm_presses_change ~ GROUP*VALUE*STAI_comb + (1|ID), data = CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
summary(no_inter.anxiety <- lmer(norm_presses_change ~ GROUP*VALUE+GROUP*STAI_comb+VALUE*STAI_comb + (1|ID), data = CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
anova(inter.anxiety,no_inter.anxiety)
Confint(inter.anxiety, level = 0.95) 

# ----- assumptions check
plot(fitted(inter.anxiety),residuals(inter.anxiety)) 
qqnorm(residuals(inter.anxiety))
hist(residuals(inter.anxiety))

# test and different points of the model to understand interaction

# ANXIETY -1 SD people low in axiety/stress have effect of overtraining
CHANGE$ANX_pSD <- scale(CHANGE$STAI_comb, scale = T) + 1 # here I'm going to test at - 1SD (so people that are low in anxiety)
sslop.pSD = lmer(norm_presses_change ~ GROUP*VALUE*ANX_pSD + (1|ID), data = CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa"))
summary(sslop.pSD)
Confint(sslop.pSD, level = 0.95) 

# ANXIETY +1 SD people high in axiety/stress have effect of overtraining
CHANGE$ANX_mSD <- scale(CHANGE$STAI_comb, scale = T) - 1 # here I'm going to test at + 1SD (so people that are high in anxiety)
sslop.mSD = lmer(norm_presses_change ~ GROUP*VALUE*ANX_mSD + (1|ID), data = CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa"))
summary(sslop.mSD)
Confint(sslop.mSD, level = 0.95) 

# -------------------- CHRONIC WORRIES ----------------------------------------
summary(inter.wory <- lmer(norm_presses_change ~ GROUP*VALUE*TICS_WORY + (1|ID), data = CHANGE, REML=FALSE,control = lmerControl(optimizer ="bobyqa")))
summary(no_inter.wory <- lmer(norm_presses_change ~ GROUP*VALUE+GROUP*TICS_WORY+VALUE*TICS_WORY + (1|ID), data = CHANGE, REML=FALSE, control = lmerControl(optimizer ="bobyqa")))
anova(inter.wory,no_inter.wory)
Confint(inter.wory , level = 0.95) 

# ----- assumptions check
plot(fitted(inter.wory),residuals(inter.wory)) 
qqnorm(residuals(inter.wory))
hist(residuals(inter.wory))

# test and different points of the model to understand interaction

# WORRIES -1 SD people low in axiety/stress have effect of overtraining
CHANGE$WORY_pSD <- scale(CHANGE$TICS_WORY, scale = T) + 1 # here I'm going to test at - 1SD (so people that are low in anxiety)
sslop.pSD = lmer(norm_presses_change ~ GROUP*VALUE*WORY_pSD + (1|ID), data = CHANGE, REML=FALSE,control = lmerControl(optimizer ="bobyqa"))
summary(sslop.pSD)
Confint(sslop.pSD, level = 0.95) 

# WORRIES +1 SD people high in axiety/stress have effect of overtraining
CHANGE$WORY_mSD <- scale(CHANGE$TICS_WORY, scale = T) - 1 # here I'm going to test at + 1SD (so people that are high in anxiety)
sslop.mSD = lmer(norm_presses_change ~ GROUP*VALUE*WORY_mSD + (1|ID), data = CHANGE, REML=FALSE,control = lmerControl(optimizer ="bobyqa"))
summary(sslop.mSD)
Confint(sslop.mSD, level = 0.95) 



# -------------------- FIGURE S2 ----------------------------------------
# this tests the model predictions as we do in lmer but does not allow to display distributions
ANXWORY.means <- aggregate(CHANGE$habit_index, by = list(CHANGE$ID, CHANGE$GROUP, CHANGE$TICS_WORY, CHANGE$STAI_comb), FUN='mean', na.rm = T) # extract means
colnames(ANXWORY.means) <- c('ID','group','Chronic_Worries','Anxiety', 'normChangeBehav')

# ADJUSTED MEANS in case we want see the estimations from the model
acqC1.anx      <- aov_car(normChangeBehav  ~ group*Anxiety +Error(ID), data = ANXWORY.means, observed = c("ANXIETY"), factorize = F, anova_table = list(es = "pes"))
acqC1.wory      <- aov_car(normChangeBehav  ~ group*Chronic_Worries +Error(ID), data = ANXWORY.means, observed = c("TICS_WORY"), factorize = F, anova_table = list(es = "pes"))


# rename variables for plot
ANXWORY.means$group    <- dplyr::recode(ANXWORY.means$group, "1-day" = "Moderate", "3-day" = "Extensive" )

#******************  anxiety ******************************************* 
pp <- ggplot(ANXWORY.means, aes(x =Anxiety, y = normChangeBehav, fill = group, color = group)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .0, jitter.height = 0)) +
  geom_smooth(method = lm, level = .95, alpha = .1, fullrange=TRUE) +
  ylab('Behavioral adaptation index') +
  xlab('Anxiety Level')+
  annotate("rect", xmin=0.95, xmax=1.05, ymin=min(ANXWORY.means$normChangeBehav), ymax=max(ANXWORY.means$normChangeBehav), alpha=0.3, fill="gray") +
  annotate("rect", xmin=-0.95, xmax=-1.05, ymin=min(ANXWORY.means$normChangeBehav), ymax=max(ANXWORY.means$normChangeBehav), alpha=0.3, fill="gray") +
  scale_fill_manual(values=c("#56B4E9", "#0F2080")) +
  scale_color_manual(values=c("#56B4E9", "#092C48")) +
  scale_x_continuous(breaks=seq(-2.5,2.5,0.5)) +
  theme_bw()

ppp <- pp + theme_continous_plot


pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1), legend.background = element_rect(color = "white")), 
                   type = "density", groupFill = T, color = NA, alpha = .2)

#pdf(file.path(figures_path,'Figure_S2_PannelA.pdf'))
print(pppp)
dev.off()

#******************  chronic worries ******************************************* 
pp <- ggplot(ANXWORY.means, aes(x =Chronic_Worries, y = normChangeBehav, fill = group, color = group)) +
  geom_point(alpha = .2, position = position_jitterdodge(jitter.width = .0, jitter.height = 0)) +
  geom_smooth(method = lm, level = .95, alpha = .1, fullrange=TRUE) +
  ylab('Behavioral adaptation index') +
  xlab('Chronic Worries Level')+
  annotate("rect", xmin=0.95, xmax=1.05, ymin=min(ANXWORY.means$normChangeBehav), ymax=max(ANXWORY.means$normChangeBehav), alpha=0.3, fill="gray") +
  annotate("rect", xmin=-0.95, xmax=-1.05, ymin=min(ANXWORY.means$normChangeBehav), ymax=max(ANXWORY.means$normChangeBehav), alpha=0.3, fill="gray") +
  scale_fill_manual(values=c("#56B4E9", "#0F2080")) +
  scale_color_manual(values=c("#56B4E9", "#092C48")) +
  scale_x_continuous(breaks=seq(-2.5,2.5,0.5)) +
  theme_bw()

ppp <- pp + theme_continous_plot


pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1), legend.background = element_rect(color = "white")), 
                   type = "density", groupFill = T, color = NA, alpha = .2)

pdf(file.path(figures_path,'Figure_S2_Pannelb.pdf'))
print(pppp)
dev.off()

