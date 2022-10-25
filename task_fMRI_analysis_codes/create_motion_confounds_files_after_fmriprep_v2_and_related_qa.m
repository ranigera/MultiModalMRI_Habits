function num_bad_volumes = create_motion_confounds_files_after_fmriprep_v2_and_related_qa(main_input_path,main_output_path_task_fMRI, main_output_path_rest_fMRI, qa_path, fd_threshold,subjects, sessions, tasks, do_QA)
%create_motion_confounds_files_after_fmriprep_v2
% created on August 2017 by rotem Botvinik Nezer
% edited on October 2018
% Adapted to HIS study and added QA stuff (see below) by Rani, January 2020
%
% this function creates confound txt files in fsl format, based on the
% confounds.tsv created by fmriprep (version 1.1.4) and the parameters we decided to use.
% the output is txt file named confounds with the following columns (no
% titles):
% std dvars, six aCompCor, FramewiseDisplacement, six motion parameters (translation and rotation each in 3 directions) +
% their squared and temporal derivatives (Friston24).
% in addition, there an additional column for each volume that should be
% extracted due to FD>fd_threshold (default value for fd threshold is 0.9).
% this function also returns as output the number of "thrown" volumes for
% each subject (based on the fd value and threshold) to the num_bad_volumes
% variable
%
% if specific subjects / sessions / tasks are specified, only them
% will be calculated. Else, the default is all subjects, sessions, tasks
% and runs. If you want all subjects/tasks/sessions you can put an empty value in the
% relevant variable
% subjects, sessions and tasks should include the 'sub-' or 'ses-' or
% 'task-' string, and be a cell (unless they are empty for all
% subjects/sessions/tasks)
%
% The function now place task and rest created confound to their dedicated
% folders.
%
% QA Added by Rani:
% ----------------------
% Calculating:
% the number of volumes
% the percentage of scrubbed volums
% a logical array for which scans to exclude (based on >15% scrubbed volumes).
% an array indicating the difference between the expected and actual number of volumes in each scan.
% Accordingly it creates three files:
% precentage_of_scrubbed_volumes_per_scan.csv
% scans_to_exclude_due_to_scrubbed_volumes.csv
% missing_volumes_per_scan.csv


tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

if nargin < 4
    qa_path = '/export2/DATA/HIS/HIS_server/analysis/QA';
    if nargin < 3
        main_output_path_rest_fMRI = '/export2/DATA/HIS/HIS_server/analysis/rest_fMRI_data';
        if nargin < 2
            main_output_path_task_fMRI = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data';
            if nargin < 1
                main_input_path = '/export2/DATA/HIS/HIS_server/BIDS/derivatives/fmriprep';
            end
        end
    end
end

if nargin < 9
    do_QA = true;
end

if nargin < 8 || isempty(tasks)
    tasks = {'task-training', 'task-extinction', 'task-reacquisition', 'task-rest'};
end

if nargin < 7 || isempty(sessions)
    sessions = {'ses-1', 'ses-2', 'ses-3'};
end

if nargin < 6 || isempty(subjects)
    subjects = dir([main_input_path '/sub-*']);
    dirs = [subjects.isdir];
    subjects = {subjects(dirs).name};
    % note that the strings will contain the 'sub-'
end

if nargin < 5
    fd_threshold = 0.9;
end

num_bad_volumes = cell(length(subjects)+1,17);
num_bad_volumes(1,:) = {'sub','ses-1_training1','ses-1_training2', 'ses-1_training3', 'ses-1_training4', 'ses-2_training1','ses-2_training2', 'ses-2_training3', 'ses-2_training4', 'ses-3_training1','ses-3_training2', 'ses-3_training3', 'ses-3_training4', 'extinction', 'reacquisition', 'RS1', 'RS2'};
num_bad_volumes(2:end,1) = subjects;
num_volumes = num_bad_volumes;
all_tasks = {'task-training', 'task-extinction', 'task-reacquisition', 'task-rest'};

for subject_ind = 1:length(subjects)
    relevantSessions = sessions;
    if str2double(subjects{subject_ind}(end-2)) == 1 % adjust for one session for the 1-day group:
        relevantSessions = {'ses-1'};
    end
    for session_ind = 1:length(relevantSessions)
        for task_ind = 1:length(tasks)
            if strcmp(tasks{task_ind},'task-training') % training
                if str2double(subjects{subject_ind}(end-2)) == 1 % 1-day group
                    runs = 1:2;
                elseif str2double(subjects{subject_ind}(end-2)) == 2 % 3-day group
                    runs = 1:4;
                end
            elseif strcmp(tasks{task_ind},'task-rest') % resting state
                if str2double(subjects{subject_ind}(end-2)) == 1 % 1-day group
                    runs = 1:2;
                elseif str2double(subjects{subject_ind}(end-2)) == 2 % 3-day group
                    runs = find(strcmp({'ses-1', 'ses-3'}, sessions(session_ind))); % assign run number by session
                end
            else % extinction and reacquisition
                runs = 1;
            end
            for run_ind = 1:length(runs)
                curr_input_dir = [main_input_path filesep subjects{subject_ind} filesep relevantSessions{session_ind} filesep 'func'];
                if strcmp(tasks{task_ind},'task-rest') % determine output dir (task/rest)
                    curr_output_dir = [main_output_path_rest_fMRI filesep subjects{subject_ind} filesep relevantSessions{session_ind} filesep];
                else
                    curr_output_dir = [main_output_path_task_fMRI filesep subjects{subject_ind} filesep relevantSessions{session_ind} filesep];
                end
                
                if strcmp(tasks{task_ind},'task-training') || strcmp(tasks{task_ind},'task-rest')
                    old_filename = [subjects{subject_ind} '_' relevantSessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(runs(run_ind)) '_desc-confounds_regressors.tsv'];
                    new_filename = [subjects{subject_ind} '_' relevantSessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(runs(run_ind)) '_desc-confounds_regressors_v2.tsv'];
                else
                    old_filename = [subjects{subject_ind} '_' relevantSessions{session_ind} '_' tasks{task_ind} '_desc-confounds_regressors.tsv'];
                    new_filename = [subjects{subject_ind} '_' relevantSessions{session_ind} '_' tasks{task_ind} '_desc-confounds_regressors_v2.tsv'];
                end
                input_filename = [curr_input_dir '/' old_filename];
                output_filename = [curr_output_dir new_filename];
                % read confounds file
                try
                    if exist(input_filename,'file')
                        confounds = tdfread(input_filename);
                    else
                        continue
                    end
                catch
                    warning(['could not open confounds file for ' subjects{subject_ind}  ' ' tasks{task_ind}]);
                    continue;
                end
                fprintf(['read confounds file of ' subjects{subject_ind}  ' ' relevantSessions{session_ind} ' ' tasks{task_ind} ' run 0' num2str(runs(run_ind)) ' in ' num2str(toc) '\n']);
                % create new confounds array
                new_confounds(:,1) = cellstr(confounds.std_dvars);
                new_confounds(:,2) = cellstr(confounds.framewise_displacement);
                new_confounds(1,1:2) = {'0'};
                new_confounds(:,1:2) = cellfun(@str2num,new_confounds(:,1:2),'UniformOutput',0);
                new_confounds(:,3) = num2cell(confounds.a_comp_cor_00);
                new_confounds(:,4) = num2cell(confounds.a_comp_cor_01);
                new_confounds(:,5) = num2cell(confounds.a_comp_cor_02);
                new_confounds(:,6) = num2cell(confounds.a_comp_cor_03);
                new_confounds(:,7) = num2cell(confounds.a_comp_cor_04);
                new_confounds(:,8) = num2cell(confounds.a_comp_cor_05);
                new_confounds(:,9) = num2cell(confounds.trans_x);
                new_confounds(:,10) = num2cell(confounds.trans_y);
                new_confounds(:,11) = num2cell(confounds.trans_z);
                new_confounds(:,12) = num2cell(confounds.rot_x);
                new_confounds(:,13) = num2cell(confounds.rot_y);
                new_confounds(:,14) = num2cell(confounds.rot_z);
                new_confounds(:,15) = num2cell((confounds.trans_x).^2);
                new_confounds(:,16) = num2cell((confounds.trans_y).^2);
                new_confounds(:,17) = num2cell((confounds.trans_z).^2);
                new_confounds(:,18) = num2cell((confounds.rot_x).^2);
                new_confounds(:,19) = num2cell((confounds.rot_y).^2);
                new_confounds(:,20) = num2cell((confounds.rot_z).^2);
                derivatives_motion_regressors = [diff(confounds.trans_x), diff(confounds.trans_y), diff(confounds.trans_z), diff(confounds.rot_x), diff(confounds.rot_y), diff(confounds.rot_z)];
                derivatives_motion_regressors = [zeros(1,6); derivatives_motion_regressors];
                new_confounds(:,21:26) = num2cell(derivatives_motion_regressors);
                new_confounds(:,27:32) = num2cell(derivatives_motion_regressors.^2);
                
                FD = cell2mat(new_confounds(:,2));
                bad_vols = FD>fd_threshold;
                num_bad_vols = sum(bad_vols);
                if strcmp(tasks{task_ind},'task-training')
                    col_name = [relevantSessions{session_ind} '_training' num2str(runs(run_ind))];
                elseif strcmp(tasks{task_ind},'task-rest')
                    col_name = ['RS' num2str(runs(run_ind))];
                elseif strcmp(tasks{task_ind},'task-extinction') || strcmp(tasks{task_ind},'task-reacquisition')
                    col_name = tasks{task_ind}(strfind(tasks{task_ind},'-')+1:end);
                end
                col_ind_for_bad_vols = find(strcmp(num_bad_volumes(1,:), col_name)); % get the relevant column index in num_bad_volumes
                
                % get the number of bad volumes
                num_bad_volumes{subject_ind+1, col_ind_for_bad_vols} = num_bad_vols;
                % get the number of volumes
                num_volumes{subject_ind+1, col_ind_for_bad_vols} = size(new_confounds, 1);
                
                
                if num_bad_vols == 0
                    fprintf('no bad volumes, based on fd threshld %f\n',fd_threshold);
                else
                    fprintf('found %d bad volumes with fd > %.2f\n', num_bad_vols,fd_threshold);
                    bad_vols_loc = find(bad_vols);
                    for vol_ind = 1:length(bad_vols_loc)
                        new_confounds(:,end+1) = {0};
                        new_confounds(bad_vols_loc(vol_ind),end) = {1};
                    end
                end
                
                % save output confounds file
                if ~exist(curr_output_dir, 'dir')
                    mkdir(curr_output_dir)
                end
                dlmwrite(output_filename,new_confounds,'delimiter','\t');
                
                fprintf(['finished ' subjects{subject_ind} ' ' relevantSessions{session_ind} ' ' tasks{task_ind} ' run 0' num2str(runs(run_ind)) ' in ' num2str(toc) '\n\n']);
                clear confounds new_confounds;
            end
        end
    end
end

%% ---------------- Added by Rani for QA purposes ------------------
if do_QA
    %%
    % calculate the percentage of bad volumes and indicate scans should be excluded:
    num_bad_volumes(cellfun(@isempty, num_bad_volumes)) = {NaN};
    num_volumes(cellfun(@isempty, num_volumes)) = {NaN};
    scrubbedPercentage = num_bad_volumes;
    scrubbedPercentage(2:end, 2:end) = num2cell(cell2mat(scrubbedPercentage(2:end, 2:end))./cell2mat(num_volumes(2:end, 2:end)));
    % logical indicator of which scan to throw
    throwScans = scrubbedPercentage;
    throwScansMat = cell2mat(throwScans(2:end,2:end));
    throwScansMat(throwScansMat > 0.15) = 1; throwScansMat(throwScansMat <= 0.15) = 0;
    throwScans(2:end,2:end) = num2cell(throwScansMat);
    
    %save QA files:
    % precentage_of_scrubbed_volumes_per_scan:
    scrubbedPercentage(1,:) = cellfun(@(x) erase(x,'-'), scrubbedPercentage(1,:) , 'UniformOutput', false);
    scrubbedPercentage = cell2table(scrubbedPercentage, 'VariableNames', scrubbedPercentage(1,:));
    writetable(scrubbedPercentage, [qa_path filesep 'precentage_of_scrubbed_volumes_per_scan.csv'], 'WriteVariableNames', false);
    fprintf(['\nThe file ' qa_path filesep 'precentage_of_scrubbed_volumes_per_scan.csv was saved.\n'])
    % scans_to_exclude_due_to_scrubbed_volumes:
    throwScans(1,:) = cellfun(@(x) erase(x,'-'), throwScans(1,:) , 'UniformOutput', false);
    throwScans = cell2table(throwScans, 'VariableNames', throwScans(1,:));
    writetable(throwScans, [qa_path filesep 'scans_to_exclude_due_to_scrubbed_volumes.csv'], 'WriteVariableNames', false);
    fprintf(['\nThe file ' qa_path filesep 'scans_to_exclude_due_to_scrubbed_volumes.csv was saved.\n'])
    
    % notify if there is any scans to exclude due to > 0.15 scrubbed volumes.
    if any(any(cell2mat(throwScans{2:end,2:end}) > 0)) %if there are no zero elements:
        fprintf('\n**************    There are scan/s with > 0.15 scrubbed volumes to EXCLUDE!    **************\n');
        fprintf(  '************** check scans_to_exclude_due_to_scrubbed_volumes.csv for detailes **************\n');
    end
    
    %%
    % test number of volumes
    expected_vs_actual_n_volumes = num_bad_volumes;
    expected_n_volumes = repmat([repelem(492,1,12), 192, 192, 600, 600], size(num_volumes,1)-1, 1);
    expected_vs_actual_n_volumes(2:end,2:end) = num2cell(expected_n_volumes - cell2mat(num_volumes(2:end, 2:end))); %difference between expected and actual number of volumes
    
    % save QA file:
    % scans_with_incorrect_n_volumes
    expected_vs_actual_n_volumes(1,:) = cellfun(@(x) erase(x,'-'), expected_vs_actual_n_volumes(1,:) , 'UniformOutput', false);
    expected_vs_actual_n_volumes = cell2table(expected_vs_actual_n_volumes, 'VariableNames', expected_vs_actual_n_volumes(1,:));
    writetable(expected_vs_actual_n_volumes, [qa_path filesep 'missing_volumes_per_scan.csv'], 'WriteVariableNames', false);
    fprintf(['\nThe file ' qa_path filesep 'missing_volumes_per_scan.csv was saved.\n'])
    
    % notify if there is any incorrect number of volumes.
    if any(any(cell2mat(expected_vs_actual_n_volumes{2:end,2:end}) > 0)) %if there are no zero elements:
        fprintf('\n**************   There are scan/s with incorrect number of volumes   **************\n');
        fprintf(  '**************    check missing_volumes_per_scan.csv for detailes    **************\n');
    end
    
end
end % end function


