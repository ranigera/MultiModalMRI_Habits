function var = defineBasicVars(var)

% Sub ID:
if ~isfield(var, 'sub_ID') % if the subID was not already entered and thus exist in the workspace.
    var.sub_ID = input('***input*** SUBJECT NUMBER: ');
end
% check validity of SUBJECT number:
while isempty(var.sub_ID) || ~isa(var.sub_ID,'double') || var.sub_ID <= 100 || var.sub_ID >= 300 || var.sub_ID == 200
    var.sub_ID = input('SUBJECT NUMBER must be 101-199 or 201-299. SUBJECT NUMBER: ');
end

% Session:
if var.sub_ID > 100 && var.sub_ID < 200
    var.session = 1;
    var.training = 1;
    var.runs = 2;
elseif var.sub_ID > 200 && var.sub_ID < 300
    if ~isfield(var, 'session') % if the session was not already entered and thus exist in the workspace.
        var.session = input('***input*** SESSION NUMBER (1, 2 or 3 session day): '); % 1,2,or 3 session
        % check validity of SESSION number:
        while isempty(var.session) || ~ismember(var.session,1:3)
            var.session = input('SESSION NUMBER must be 1, 2 or 3. SESSION NUMBER: '); % 1,2,or 3 session
        end
    end
    var.training = 3;
    var.runs = 4;
end

end
