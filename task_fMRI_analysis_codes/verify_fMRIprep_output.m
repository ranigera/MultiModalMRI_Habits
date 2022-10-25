function verify_fMRIprep_output()
% Check the fMRIprep summary html files for errors.

% Parameters:
% ------------
fMRIprepDerivativeFolder = '/export2/DATA/HIS/HIS_server/BIDS/derivatives/fmriprep/';

% Executing:
% ------------
[~, n_subs] = system(['ls -l -d ' fMRIprepDerivativeFolder 'sub-*/ | wc -l']);
[~, n_no_errors] = system(['grep -i -c -o "No errors to report" ' fMRIprepDerivativeFolder '*.html | wc -l']);
if str2double(n_subs) == str2double(n_no_errors)
    disp('** NO ERRORS in fMRIprep preprocessing (for all subjects).')
else
    [~, subs_txt] = system(['ls -d ' fMRIprepDerivativeFolder 'sub-*/']);
    [~, no_errors_txt] = system(['grep -i -o "No errors to report" ' fMRIprepDerivativeFolder '*.html']);
    fprintf('** THERE ARE ERRORS in at least one subject fMRIprep preprocessing.\nN subjects: %d | Outputs with no errors: %d\n\nSee the following lists to identify where there are errors:\nSubjects:\n%s\nNo Errors output:\n%s\n', str2double(n_subs), str2double(n_no_errors), subs_txt, no_errors_txt)
end

end