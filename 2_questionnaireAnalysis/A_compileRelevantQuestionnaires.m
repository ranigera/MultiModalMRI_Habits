%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compile questionnaires (total and subscales)
% Adapted from Eva Pool's code used for the project of Pool et al. 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified on Aug 2022 by Rani

close all; clear all

%% params
behav_data_file = '../1_behaviorAnalysis/my_databases/txt_data/presses_HIS_May_2022.csv';
behav_data_subgroups_file = '../1_behaviorAnalysis/my_databases/txt_data/clustered_subgroups_HIS_May_2022.csv';
questionnaire_data_file = 'HIS - BIS_STAI_TICS Questionnaires data for EFA.csv';
output_questionnaire_scores_file  = 'HIS_QUESTIONNARE_SCORES.csv';
output_questionnaire_scores_subgroups_file  = 'HIS_QUESTIONNARE_SCORES_w_subgroups_scores.csv';

%% read data
behav_data = readtable(behav_data_file);
behav_data_subgroups = readtable(behav_data_subgroups_file);
questionnaire_data = readtable(questionnaire_data_file);

%% participants
valid_subj = unique(behav_data.ID);
% remove invalid participants:
questionnaire_data = questionnaire_data(ismember(questionnaire_data.ID,valid_subj),:);
% sort by subID:
questionnaire_data = sortrows(questionnaire_data);

%% BIS 11
B = questionnaire_data{:,contains(questionnaire_data.Properties.VariableNames,'BIS')};
reverse_list = [1, 7, 8, 9, 10, 12, 13, 20, 29,  30];

for i = 1:length(reverse_list)
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;
end

list_all   = [{[5 9 11 29 28 6 24 26]}; {[2 3 4 17 19 22 25 16 21 23 30]}; {[1 7 8 12 13 14 10 15 18 27 29]}];
scaleNames = {'BIS_attentional'     ;                     'BIS_motor';          'BIS_nonplanning'};
 
for i = 1:length(scaleNames)    
    list = cell2mat(list_all(i));
    name = char(scaleNames(i));  
    subscale.(name) = zeros(size(B,1),1);    
    for ii = 1:length(list)       
        item = list (ii);
        subscale.(name) = (subscale.(name) + B(:,item));%  here we compute the average because different versions (long or short) have been used by different sites      
    end  
        subscale.(name) = sum(subscale.(name),2)/ii;
end

subscale.BIS_total       = subscale.BIS_attentional + subscale.BIS_motor + subscale.BIS_nonplanning;
BIS.all.data    = [subscale.BIS_attentional, subscale.BIS_motor,  subscale.BIS_nonplanning,  subscale.BIS_total];
BIS.all.headers = [{'BIS_attentional'},                     {'BIS_motor'},       {'BIS_nonplanning'},       {'BIS_total'}];

%% STAI-S
B = questionnaire_data{:,contains(questionnaire_data.Properties.VariableNames,'STAIS')};
reverse_list = [1, 2, 5, 8, 10, 11, 15, 16, 19 20];

for i = 1:length(reverse_list) 
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;   
end

STAIS_total = sum(B,2);
STAIS.all.data = STAIS_total;
STAIS.all.headers = [{'STAIS_total'}];

%% STAI-T
B = questionnaire_data{:,contains(questionnaire_data.Properties.VariableNames,'STAIT')};
reverse_list = [1, 3, 6, 7, 10, 13, 14, 16, 19];

for i = 1:length(reverse_list)
    ii = reverse_list(i); 
    B(:,ii) = B(:,ii) * -1 + 5;
end

STAIT_total = sum(B,2);
STAIT.all.data = STAIT_total;
STAIT.all.headers = [{'STAIT_total'}];

%% TICS
B = questionnaire_data{:,contains(questionnaire_data.Properties.VariableNames,'TICS')};

list_all   = [{[01 04 17 27 38 44 50 54]}; {[07, 19, 28, 39, 49, 57]}; {[08, 12, 14, 22, 23, 30, 32, 40, 43]}; {[05, 10, 13, 21, 37, 41, 48, 53]}; {[03, 20, 24, 35, 47, 55]};  {[02, 18, 31, 46]}; {[06, 15, 26, 33, 45, 52]}; {[11, 29, 34, 42, 51, 56]}; {[9, 16, 25, 36]}; {[09, 16, 18, 25, 31, 35, 36, 38, 44, 47, 54, 57]}];
scaleNames = {'TICS_WOOV'                ;                'TICS_SOOV';                           'TICS_PREPE';                       'TICS_WODI';                 'TICS_EXWO';         'TICS_LACK';                'TICS_SOTE';                'TICS_SOIS';       'TICS_WORY';                                       'TICS_CSSS' };
 
for i = 1:length(scaleNames) 
    list = cell2mat(list_all(i));
    name = char(scaleNames(i));   
    subscale.(name) = zeros(size(B,1),1);   
    for ii = 1:length(list)     
        item = list (ii);
        subscale.(name) = subscale.(name) + B(:,item);      
    end   
end

TICS.all.data = [ subscale.TICS_WOOV, subscale.TICS_SOOV, subscale.TICS_PREPE, subscale.TICS_WODI, subscale.TICS_EXWO, subscale.TICS_LACK, subscale.TICS_SOTE, subscale.TICS_SOIS, subscale.TICS_WORY, subscale.TICS_CSSS];
TICS.all.headers = [            {'TICS_WOOV'},      {'TICS_SOOV'},      {'TICS_PREPE'},      {'TICS_WODI'},       {'TICS_EXWO'},      {'TICS_LACK'},     {'TICS_SOTE'},        {'TICS_SOIS'},    {'TICS_WORY'},       {'TICS_CSSS'}];

%% get habit index
habit_index = behav_data{strcmp(behav_data.VALUE,'valued'),'habit_index'};

%% write scores data
headers    = ['ID',                 'habit_index', BIS.all.headers, TICS.all.headers, STAIS.all.headers, STAIT.all.headers];
Rdatabase  = [questionnaire_data.ID, habit_index,  BIS.all.data   , TICS.all.data   , STAIS.all.data,    STAIT.all.data];
scores_table = array2table(Rdatabase,"VariableNames",headers);
writetable(scores_table, output_questionnaire_scores_file);

% create a file for the subgroups (because there are there some changes to the behavioral data and
% removal of some subjects)
scores_table_subgroups = scores_table;
scores_table_subgroups = sortrows(scores_table_subgroups);
scores_table_subgroups = scores_table_subgroups(ismember(scores_table_subgroups.ID,behav_data_subgroups.ID),:);

%change habit index to adjust to adaptations (in the subgroups analysis):
scores_table_subgroups.habit_index = behav_data_subgroups.habit_score;
writetable(scores_table_subgroups, output_questionnaire_scores_subgroups_file);

