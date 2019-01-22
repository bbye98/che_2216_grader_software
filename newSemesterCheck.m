function [] = newSemesterCheck(user_pref)
% newSemesterCheck: Checks to see if it is the beginning of a new semester
% and sets up individual student folders and a local gradebook if it is.

q_newSemester = questdlg('Is this the beginning of a new semester?', '', 'Yes', 'No', 'No');
if strcmp(q_newSemester, 'Yes')
    optRow = contains(user_pref(:, 1), 'opt_show_instructions_roster');
    if user_pref{optRow, 2} == 1
        help_1 = '1) Visit the Roster section of the class''s UVACollab page and select the Export tab.\n';
        help_2 = '2) Download the Microsoft Excel spreadsheet to the same directory as gradingScript.m.\n';
        help_3 = '3) Make sure that the file you just downloaded is the only .xlsx file in the directory where gradingScript.m is found.';
        q_instructions = questdlg(sprintf([help_1 help_2 help_3]), 'Instructions', 'Ready', 'Not Ready', 'Don''t Show Again', 'Not Ready');
        if strcmp(q_instructions, 'Don''t Show Again')
            user_pref{optRow, 2} = 0;
            save('user_pref.mat', 'user_pref')
        end
    end
    excelLookup = dir('*.xlsx');
    if isempty(excelLookup)
        msgbox('No student roster in Microsoft Excel format was found in the current directory.', '', 'error')
        error('Error: See error message in pop-up message box.')
    elseif length({excelLookup.name}) > 1
        msgbox('More than one Microsoft Excel workbook was found in the current directory.', '', 'error')
        error('Error: See error message in pop-up message box.')
    end
    q_createFolders = questdlg('Local student folders and a gradebook will be created now.', '', 'Proceed', 'Abort', 'Abort');
    if strcmp(q_createFolders, 'Proceed')
        if ~ exist('Students', 'dir')
            mkdir Students
        end
        [~, roster] = xlsread(excelLookup.name);
        cd Students
        studentRows = strcmp(roster(:, end), 'Student');
        roster = roster(studentRows, :);
        numStudents = size(roster, 1);
        studentDir = dir;
        studentDir = {studentDir(3:end).name};
        for studentInd = 1:numStudents
            student = [roster{studentInd, 1} '(' roster{studentInd, 2} ')'];
            if isempty(find(strcmp(studentDir, student), 1))
                mkdir(student)
            end
        end
        waitfor(msgbox('Student folders have successfully been set up.', '', 'help'))
        gradebook = cell(numStudents + 1, 2);
        gradebook(1, 1:2) = {'Student' 'Computing ID'};
        for studentInd = 1:numStudents
            gradebook(studentInd + 1, :) = roster(studentInd, 1:2);
        end
        if ~ exist('gradebook.mat', 'file')
            save('gradebook.mat', 'gradebook')
        elseif exist('gradebook.mat', 'file') == 2
            overwrite = questdlg('A local gradebook already exists. Would you like to overwrite the existing file?', '', 'Yes', 'No', 'No');
            if strcmp(overwrite, 'Yes')
                save('gradebook.mat', 'gradebook')
            end
        end
        waitfor(msgbox('A local gradebook has successfully been set up.', 'Success', 'help'))
        cd ..
        if ~ exist('Assignments', 'dir')
            mkdir Assignments
        end
    end
end
end