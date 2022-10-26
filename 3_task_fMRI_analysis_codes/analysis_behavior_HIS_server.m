%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANALYSIS SCRIPT FOR HABITS - HIS - replication of the and extension of the
% imaging study by Tricomi et al., 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified on May 2020 by Rani just to extract, calculate and save the
% files ON THE SERVER, to then correlate with the neuroimaging data.

close all
clear

%% INPUT VARIABLE
extract_subj_data          = 1;
save_results               = 1;

%% PARAMETERS
%time = strsplit(date,'-');
%analysis_name      = ['HIS_' time{2} '_' time{3}];
analysis_name      = 'HIS_behavior';

% DIRECTORIES:
% codes:
homedir                   = '../1_behaviorAnalysis/';
folderWithRelevantSubjects        = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/'; % change this so that it correspond to your fMRI analysis folder
% data:
behavDataFolder           = '../1_behaviorAnalysis/raw_behavioral_data/';
% output folders:
matlab_extracted_data_dir = fullfile(homedir, 'my_databases/matlab_data/');
txt_dir                   = fullfile(homedir, 'my_databases/txt_data/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GET PARTICIPANTS

% assemble participant list:
subFolders = dir([folderWithRelevantSubjects 'sub*']);
subj = cellfun(@(x) x(end-2:end), {subFolders.name},'UniformOutput',false)';
% Assign groups:
group    = [ones(1,sum(str2double(subj)<200)) ones(1,sum(str2double(subj)>200))*2];

%% LOOP TO EXTRACT DATA
if extract_subj_data
    for  i=1:length(subj)
        %% LOAD DATA
        subjX=char(subj(i,1)); % which subject?
        disp (['******************************* PARTICIPANT: ' subjX ' ***************************************']);
        groupX = group(i); % which group did the subject belong?
        
        switch groupX % get the specifics according to the group (1 vs 3 days)
            case 1
                session   = {'01'};
                task_name = 'HAB1day';
                groupName = {'1'};%{'1-day'};
            case 2
                session = {'01'; '02'; '03'};
                task_name = 'HAB3day';
                groupName = {'3'};%{'3-day'};
        end
        
        for ii = 1:length(session)
            sessionX = char(session(ii,1));
            % load task data (collected in the MRI):
            load ([behavDataFolder 'sub-' num2str(subjX) '/1-data/sub-' num2str(subjX) '_HIS_MRI_' groupName{:} 'day_session-' num2str(sessionX(end-1:end)) '.mat']);
            DATA.(['day' num2str(ii)]) = data;
            
            % load ratings data (collected in the behavioral room):
            load ([behavDataFolder 'sub-' num2str(subjX) '/1-data/sub-' num2str(subjX) '_HIS_' groupName{:} 'day_session-' num2str(sessionX(end-1:end)) '.mat']);
            
            % append the relevant fields:
            DATA.(['day' num2str(ii)]).SubHourRatings = data.SubHour; % first add the subHours of the ratings:
            ratingsDataFields = fieldnames(data);
            % now add all field that not already there (common fields)
            for fieldInd = 1:length(ratingsDataFields)
                if ~ismember(ratingsDataFields{fieldInd}, fieldnames(DATA.(['day' num2str(ii)])))
                    DATA.(['day' num2str(ii)]).(ratingsDataFields{fieldInd}) = data.(ratingsDataFields{fieldInd});
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% ASSEMBLE RATINGS DATA
        % database for devaluation manipulation check
        if strcmp(DATA.day1.target, 'sweet')
            %ratings.pre.val(:,i)             = DATA.day1.initialRatings.savory;
            %ratings.pre.deval(:,i)           = DATA.day1.initialRatings.sweet;
            %ratings.pre.hunger(:,i)          = DATA.day1.initialRatings.hunger;
            % NEW, pre-ratings of the last session day, not 1st day as in habits_analysis_old.m // added by Mladena
            ratings.pre.val(:,i)            = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.savory;
            ratings.pre.deval(:,i)          = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.sweet;
            ratings.pre.hunger(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.hunger;
            
            ratings.post.val(:,i)            = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.salty;
            ratings.post.deval(:,i)          = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.sweet;
            ratings.post.hunger(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.hunger;
            
            ratings.afterExperiment.val(:,i)            = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.salty;
            ratings.afterExperiment.deval(:,i)          = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.sweet;
            ratings.afterExperiment.hunger(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.hunger;
            
            % not pre-registered
            ratings.fractal.val(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.salty;
            ratings.fractal.deval(:,i)       = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.sweet;
            ratings.fractal.baseline(:,i)    = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.baseline;
            
            ratings.contingency.val(:,i)     = DATA.day1.contingencyTest.salty;
            ratings.contingency.deval(:,i)   = DATA.day1.contingencyTest.sweet;
            ratings.contingency.baseline(:,i)= DATA.day1.contingencyTest.baseline;
            
        elseif strcmp(DATA.day1.target, 'salty')
            % NEW, pre-ratings of the last session day, not 1st day as in habits_analysis_old.m // added by Mladena
            ratings.pre.val(:,i)            = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.sweet;
            ratings.pre.deval(:,i)          = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.savory;
            ratings.pre.hunger(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).initialRatings.hunger;
            
            ratings.post.val(:,i)           = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.sweet;
            ratings.post.deval(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.salty;
            ratings.post.hunger(:,i)        = DATA.(['day' num2str(length(fieldnames(DATA)))]).finalRatings.hunger;
            
            ratings.afterExperiment.val(:,i)           = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.sweet;
            ratings.afterExperiment.deval(:,i)         = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.salty;
            ratings.afterExperiment.hunger(:,i)        = DATA.(['day' num2str(length(fieldnames(DATA)))]).postExperimentalRatings.hunger;
            
            % not pre-registered
            ratings.fractal.val(:,i)        = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.sweet;
            ratings.fractal.deval(:,i)      = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.salty;
            ratings.fractal.baseline(:,i)   = DATA.(['day' num2str(length(fieldnames(DATA)))]).fractalLiking.baseline;
            
            ratings.contingency.val(:,i)     = DATA.day1.contingencyTest.sweet;
            ratings.contingency.deval(:,i)   = DATA.day1.contingencyTest.salty;
            ratings.contingency.baseline(:,i)= DATA.day1.contingencyTest.baseline;
        end
        
        Rfood.liking (:,i)         = [ratings.pre.deval(:,i); ratings.pre.val(:,i);ratings.pre.hunger(:,i);ratings.post.deval(:,i);ratings.post.val(:,i); ratings.post.hunger(:,i); ratings.afterExperiment.deval(:,i) ; ratings.afterExperiment.val(:,i); ratings.afterExperiment.hunger(:,i) ];
        Rfood.value (:,i)          = {'deval'               ;'val'                ;'hunger'               ;'deval'                ;'val'                ;'hunger'                 ;'deval'                             ;'val'                            ;'hunger'                             };
        Rfood.time (:,i)           = {'pre'                 ;'pre'                ;'pre'                  ;'post'                 ;'post'               ;'post'                   ;'afterExperiment'                   ;'afterExperiment'                ;'afterExperiment'                    };
        Rfood.ID (:,i)             = repmat(str2double(subjX),length (Rfood.time(:,i)),1);
        Rfood.group (:,i)          = repmat(groupName,length (Rfood.time(:,i)),1);
        
        Rfractal.liking (:,i)      = [ratings.fractal.deval(:,i)    ; ratings.fractal.val(:,i)    ;ratings.fractal.baseline(:,i)];
        Rfractal.contingency (:,i) = [ratings.contingency.deval(:,i); ratings.contingency.val(:,i);ratings.contingency.baseline(:,i)];
        Rfractal.value (:,i)       = {'deval'                       ;'val'                        ;'baseline'   };
        Rfractal.ID  (:,i)         = repmat(str2double(subjX),length (Rfractal.value(:,i)),1);
        Rfractal.group (:,i)       = repmat(groupName,length (Rfractal.value(:,i)),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% ASSEMBLE INSTRUMENTAL RESPONDING DATA
        % get the last run of the last day index
        idx.run      = find(DATA.(['day' num2str(length(fieldnames(DATA)))]).training.run == max(DATA.(['day' num2str(length(fieldnames(DATA)))]).training.run));
        
        list_name = {'valued'; 'devalued'; 'baseline'};
        
        for ii = 1:length(list_name)
            name = char (list_name (ii));
            
            % get the specifics of the condition during TRAINING
            idx.(name) = strcmp(DATA.(['day' num2str(length(fieldnames(DATA)))]).training.value, name);
            idx.(name) = idx.(name) (idx.run);
            % get the specifics of the condition during the last run
            frequence  = DATA.(['day' num2str(length(fieldnames(DATA)))]).training.pressFreq (idx.run);
            % get  mean responding by condition during last run
            responding.pre.(name) (:,i) = nanmean(frequence(idx.(name)));
            
            % get the specific of the condition during EXTINCTION
            idx.(name) = strcmp(DATA.(['day' num2str(length(fieldnames(DATA)))]).extinction.value, name);
            % get mean responding by condition during extinction
            responding.post.(name) (:,i) = nanmean(DATA.(['day' num2str(length(fieldnames(DATA)))]).extinction.pressFreq (idx.(name)));
            % exploratory:
            firstmin = DATA.(['day' num2str(length(fieldnames(DATA)))]).extinction.pressFreq (idx.(name));
            responding.post1min.(name) (:,i) = firstmin(1);
            
            % get the specific of the condition during REACQUISITION
            idx.(name) = strcmp(DATA.(['day' num2str(length(fieldnames(DATA)))]).reacquisition.value, name);
            % get mean responding by condition during extinction
            responding.reacquisition.(name) (:,i) = nanmean(DATA.(['day' num2str(length(fieldnames(DATA)))]).reacquisition.pressFreq (idx.(name)));
            % exploratory:
            firstmin = DATA.(['day' num2str(length(fieldnames(DATA)))]).reacquisition.pressFreq (idx.(name));
            responding.reacquisition1min.(name) (:,i) = firstmin(1);
            
            % compute the differential index (post - pre) that will be our DV of
            % interest
            pressxsec.(name) (:,i) = responding.post.(name) (:,i) - responding.pre.(name) (:,i);
            pressxsec1min.(name) (:,i)  = responding.post1min.(name) (:,i) - responding.pre.(name) (:,i);
            
        end
        
        Rresponding.pre(:,i)          = [responding.pre.valued(:,i) ; responding.pre.devalued(:,i) ; responding.pre.baseline(:,i)] ;
        Rresponding.post(:,i)         = [responding.post.valued(:,i); responding.post.devalued(:,i); responding.post.baseline(:,i)];
        Rresponding.reacquisition(:,i)= [responding.reacquisition.valued(:,i); responding.reacquisition.devalued(:,i); responding.reacquisition.baseline(:,i)];
        Rresponding.change(:,i)       = [pressxsec.valued(:,i); pressxsec.devalued(:,i); pressxsec.baseline(:,i)];
        Rresponding.value(:,i)        = {             'valued';              'devalued';              'baseline'};
        Rresponding.group(:,i)        = repmat(groupName,length (Rresponding.value(:,i)),1);
        Rresponding.ID(:,i)           = repmat(str2double(subjX),length (Rresponding.value(:,i)),1);
        % GET CHANGE/HABIT INDEX FOR EACH PARTICIPANT (change in valued - change in devlued)
        Rresponding.habit_index(:,i)       =  pressxsec.valued(:,i) - pressxsec.devalued(:,i);
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CREATE VARIABLE WITH DIFFERENCE INDEX FOR EACH GROUP
    
    list_group = {'day1'; 'day3'};
    
    for ii = 1:length(list_group) % iterate over groups
        groupvar = char(list_group(ii));
        idx.group.(groupvar) = find(group == ii); % get indices of participants in this group
        
        for iii = 1:length(list_name) % iterate over conditions
            name = char (list_name (iii));
            
            % gather the main dependent variable(s) by group:
            pressxsec.group.(groupvar).(name) = pressxsec.(name)(idx.group.(groupvar));
            presspost.group.(groupvar).(name) = responding.post.(name)(idx.group.(groupvar));
            
            pressxsec1min.group.(groupvar).(name) = pressxsec1min.(name)(idx.group.(groupvar));
            presspost1min.group.(groupvar).(name) = responding.post1min.(name)(idx.group.(groupvar));
            
            % gather the raw average presses by group
            responding.pre.group.(groupvar).(name) = responding.pre.(name)(idx.group.(groupvar));
            responding.post.group.(groupvar).(name) = responding.post.(name)(idx.group.(groupvar));
            responding.reacquisition.group.(groupvar).(name) = responding.reacquisition.(name)(idx.group.(groupvar));
        end
        
        % Assemble the change/habit index by group
        change_index.(groupvar) = Rresponding.habit_index(idx.group.(groupvar));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% SAVE EXTRACTED DATA IN A .mat FILE
    if save_results == 1
        save ([matlab_extracted_data_dir analysis_name '.mat'])
    end
    
elseif extract_subj_data == 0 % get extracted data previously extracted .mat file
    load ([matlab_extracted_data_dir analysis_name '.mat'])
end

%% EXPORT DATA FOR R ANALYSIS
if save_results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FOOD RATING DATABASE: Rfood
    
    ID   = num2cell(Rfood.ID(:));
    % IV
    GROUP = Rfood.group(:);
    VALUE = Rfood.value(:);
    TIME  = Rfood.time(:);
    % DV
    liking = num2cell(Rfood.liking(:));
    % database
    database = [ID, GROUP, VALUE, TIME, liking];
    
    % write database in txt file
    fid = fopen([txt_dir 'food_liking_' analysis_name '.txt'],'wt');
    % print header
    fprintf (fid, '%s\t%s\t%s\t%s\t%s\n',...
        'ID','group','value', 'time', 'liking');
    % print data
    formatSpec = '%d\t%s\t%s\t%s\t%d\n';
    [nrows, ~] = size(database);
    for row = 1:nrows
        fprintf(fid,formatSpec,database{row,:});
    end
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FRACTAL RATING DATABASE: Rfractal
    
    ID   = num2cell(Rfractal.ID(:));
    % IV
    GROUP = Rfractal.group(:);
    VALUE = Rfractal.value(:);
    % DV
    liking      = num2cell(Rfractal.liking(:));
    contingency = num2cell(Rfractal.contingency(:));
    % database
    database = [ID, GROUP, VALUE, liking, contingency];
    
    % write database in txt file
    fid = fopen([txt_dir 'fractal_ratings_' analysis_name '.txt'],'wt');
    % print heater
    fprintf (fid, '%s\t%s\t%s\t%s\t%s\n',...
        'ID','group','value', 'liking', 'contingency');
    % print data
    formatSpec = '%d\t%s\t%s\t%d\t%d\n';
    [nrows, ~] = size(database);
    for row = 1:nrows
        fprintf(fid,formatSpec,database{row,:});
    end
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% INSTRUMENTAL RESPONDING DATABASE: Rresponding
    
    ID   = num2cell(Rresponding.ID(:));
    % IV
    GROUP = Rresponding.group(:);
    VALUE = Rresponding.value(:);
    
    % DV
    presses_pre           = num2cell(Rresponding.pre(:));
    presses_post          = num2cell(Rresponding.post(:));
    presses_reacquisition = num2cell(Rresponding.reacquisition(:));
    presses_change        = num2cell(Rresponding.change(:));
    % Create the variabe of change/habit index for the table:
    habit_index = repelem(Rresponding.habit_index(:), length(list_name));
    
    % database
    database = table(ID, GROUP, VALUE, presses_pre, presses_post, presses_reacquisition, presses_change, habit_index);
    % write database in csv file
    writetable(database, [txt_dir 'presses_' analysis_name '.csv'])
    
end

clear

