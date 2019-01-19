if exist('user_pref.mat', 'file') ~= 2
    user_pref = cell(2, 2);
    user_pref(:, 1) = {'opt_show_instructions_roster'; 'opt_show_instructions_submissions'};
    user_pref{:, 2} = [1; 1];
    save('user_pref.mat', user_pref)
end
load('user_pref.mat')
newSemesterCheck(user_pref)
if exist('Students', 'dir')
    newAssignmentCheck(user_pref)
    if size(struct2cell(dir('Assignments')), 2) > 2
        gradeAssignment()
    end
end
