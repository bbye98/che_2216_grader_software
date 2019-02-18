function [] = newAssignmentCheck(user_pref)
% newAssignmentCheck: Checks to see if a new assignment is to be added to
% the local gradebook and eventually graded. Uncompresses a .zip archive
% containing student-submitted files and distributes them into the
% individual student folders. Asks the user for the number of problems, the
% number of parts per problem, the point values of each part, and the
% number of required submission files and the type of files they are.

origDir = pwd;
q_newAssignment = questdlg('Would you like to set up a new assignment?', '', 'Yes', 'No', 'No');
if strcmp(q_newAssignment, 'Yes')
    optRow = contains(user_pref(:, 1), 'opt_show_instructions_submissions');
    if user_pref{optRow, 2} == 1
        warning = 'WARNING: If the assignment has already been set up, proceeding with this program will overwrite the current data.\n\n';
        help_1 = '1) Click Grade under the assignment you would like to grade under the Assignments tab on UVACollab.\n';
        help_2 = '2) Select Download All and check the All checkbox before pressing the blue Download button.\n';
        help_3 = '3) Download the file attachments that the students have submitted to the same directory as gradingScript.m. The file should be named bulk_download and should be a .zip archive.\n';
        help_4 = '4) Make sure that the file you just downloaded is the only .zip archive in the directory where gradingScript.m is found.';
        q_instructions = questdlg(sprintf([warning help_1 help_2 help_3 help_4]), '', 'Ready', 'Not Ready', 'Don''t Show Again', 'Not Ready');
        if strcmp(q_instructions, 'Don''t Show Again')
            user_pref{optRow, 2} = 0;
            save('user_pref.mat', 'user_pref')
        end
    end
    zipLookup = dir('*.zip');
    if isempty(zipLookup)
        msgbox('No compressed archive file was found in the current directory.', '', 'error')
        error('Error: See error message in pop-up message box.')
    elseif length({zipLookup.name}) > 1
        msgbox('More than one compressed archive file was found in the current directory.', '', 'error')
        error('Error: See error message in pop-up message box.')
    end
    q_moveSubmissions = questdlg('The downloaded files will now be moved into the students'' folders. This may take a while.', '', 'Proceed', 'Abort', 'Abort');
    if strcmp(q_moveSubmissions, 'Proceed')
        mkdir temp
        unzip(zipLookup.name, 'temp')
        cd temp
        tempDir = struct2cell(dir)';
        assignmentName = tempDir{end, 1};
        cd(assignmentName)
        studentList = struct2cell(dir)';
        studentList = studentList(3:end - 1, 1);
        tempDir = pwd;
        for studentInd = 1:length(studentList)
            cd([origDir '\Students\' studentList{studentInd}])
            if ~ exist(assignmentName, 'dir')
                mkdir(assignmentName)
            end
            cd([tempDir '\' studentList{studentInd} '\Submission attachment(s)'])
            movefileCheck = struct2cell(dir)';
            if size(movefileCheck, 1) > 2
                movefile('*', [origDir '\Students\' studentList{studentInd} '\' assignmentName])
            end
            cd(tempDir)
        end
        cd(origDir)
        try
            rmdir temp s
        catch
            waitfor(msgbox('Some files in the temporary directory is in use, so the temporary directory cannot be deleted.'))
        end
        waitfor(msgbox('The downloaded files have successfully been distributed into the students'' folders.', '', 'help'))
        q_deleteDownload = questdlg('Would you like to delete the bulk_download.zip archive?', '', 'Yes', 'No', 'No');
        if strcmp(q_deleteDownload, 'Yes')
            delete bulk_download.zip
        end
        load('Students\gradebook.mat', 'gradebook');
        duplicateIndex = find(contains(gradebook(1, :), assignmentName), 1);
        q_duplicateGradebookClear = 'No';
        if duplicateIndex > 0
            q_duplicateGradebookClear = questdlg([assignmentName ' already exists. Would you like to clear the grades for ' assignmentName '?'], '', 'Yes', 'No', 'No');
            if strcmp(q_duplicateGradebookClear, 'Yes')
                gradebook(2:end, duplicateIndex) = {[]};
            end
        else
            gradebook(1, size(gradebook, 2) + 1) = {assignmentName};
        end
        save([origDir '\Students\gradebook.mat'], 'gradebook')
        cd Assignments
        q_duplicateAssignmentOverwrite = 'Yes';
        if exist(assignmentName, 'dir') == 7
            q_duplicateAssignmentOverwrite = questdlg([assignmentName ' has already been set up or partially set up. Would you like to set it up again and overwrite current settings?'], '', 'Yes', 'No', 'No');
        end
        if strcmp(q_duplicateAssignmentOverwrite, 'Yes')
            if ~ exist(assignmentName, 'dir')
                mkdir(assignmentName)
            end
            q_numProblems = str2double(inputdlg({['How many problems are there in ' assignmentName '?']}));
            while isnan(q_numProblems) || q_numProblems < 1
                waitfor(msgbox('You have entered text, an invalid value, or nothing. Please try again.', 'Error', 'error'))
                q_numProblems = str2double(inputdlg({['How many problems are there in ' assignmentName '?']}));
            end
            prompt_numParts = cell(q_numProblems, 1);
            for q_numProblems = 1:q_numProblems
                prompt_numParts{q_numProblems} = ['How many parts are there in Problem ' num2str(q_numProblems) '?'];
            end
            q_numParts = str2double(inputdlg(prompt_numParts));
            while ~ isempty(find(isnan(q_numParts), 1)) || ~ isempty(find(q_numParts < 1, 1))
                waitfor(msgbox('You have entered text, an invalid value, or nothing. Please try again.', 'Error', 'error'))
                q_numParts = str2double(inputdlg(prompt_numParts));
            end
            save([assignmentName '\numParts.mat'], 'q_numParts')
            alphabet = 'abcdefghijklmnopqrstuvwxyz';
            prompt_pointValues = cell(max(q_numParts), q_numProblems);
            for q_numProblems = 1:q_numProblems
                for partNum = 1:q_numParts(q_numProblems)
                    if q_numParts(q_numProblems) > 1
                        prompt_pointValues{partNum, q_numProblems} = ['How many point(s) is Problem ' num2str(q_numProblems) alphabet(partNum) ' worth?'];
                    else
                        prompt_pointValues{partNum, q_numProblems} = ['How many point(s) is Problem ' num2str(q_numProblems) ' worth?'];
                    end
                end
            end
            q_pointValues = NaN(q_numProblems, max(q_numParts));
            for prob = 1:q_numProblems
                q_pointValues(prob, 1:q_numParts(prob)) = str2double(inputdlg(prompt_pointValues(1:q_numParts(prob), prob)));
                while ~ isempty(find(isnan(q_pointValues(prob, 1:q_numParts(prob))), 1)) || ~ isempty(find(q_pointValues(prob, 1:q_numParts(prob)) < 1, 1))
                    waitfor(msgbox('You have entered text, an invalid value, or nothing. Please try again.', 'Error', 'error'))
                    q_pointValues(prob, 1:q_numParts(prob)) = str2double(inputdlg(prompt_pointValues(1:q_numParts(prob), prob)));
                end
            end
            save([assignmentName '\pointValues.mat'], 'q_pointValues')
            q_numFiles = zeros(length(q_numParts), 1);
            for prob = 1:q_numProblems
                q_numFiles(prob) = str2double(inputdlg(['How many files do students have to submit for Problem ' num2str(prob) ' of ' assignmentName '?']));
                while isnan(q_numFiles(prob)) || q_numFiles(prob) < 0
                    waitfor(msgbox('You have entered text, an invalid value, or nothing. Please try again.', 'Error', 'error'))
                    q_numFiles(prob) = str2double(inputdlg(['How many files do students have to submit for Problem ' num2str(prob) ' of ' assignmentName '?']));
                end
            end
            q_text_sol = questdlg('Is there a text solutions file?', '', 'Yes', 'No', 'No');
            q_counter = 1;
            q_submissionList = cell(sum(q_numFiles), 3);
            prompt_fileNames = cell(max(q_numFiles), length(q_numParts));
            suffix = {'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th'};
            for q = 1:q_numProblems
                for fileNum = 1:q_numFiles(q)
                    if mod(fileNum, 10) == 0
                        prompt_fileNames{fileNum, q} = ['What is the complete file name and extension of the ' num2str(fileNum) 'th file for Problem ' num2str(q) '?'];
                    else
                        prompt_fileNames{fileNum, q} = ['What is the complete file name and extension of the ' num2str(fileNum) suffix{mod(fileNum, 10)} ' file for Problem ' num2str(q) '?'];
                    end
                end
                if q_numFiles(q) > 0
                    q_submissionList(q_counter:sum(q_numFiles(1:q)), 1:2) = [num2cell(q * ones(q_numFiles(q), 1)) inputdlg(prompt_fileNames(1:q_numFiles(q), q))];
                end
                illegalChars = '[\/:*?"<>|]';
                while ~ isempty(find(~ contains(q_submissionList(q_counter:sum(q_numFiles(1:q)), 2), '.'), 1)) || ~ isempty(find(cellfun(@isempty, q_submissionList(q_counter:sum(q_numFiles(1:q)), 2)), 1)) || ~ isempty(find(~ cellfun(@isempty, regexp(q_submissionList(q_counter:sum(q_numFiles(1:q)), 2), illegalChars)), 1))
                    if ~ isempty(find(~ contains(q_submissionList(q_counter:sum(q_numFiles(1:q)), 2), '.'), 1))
                        waitfor(msgbox('At least one file name does not have a file extension. Please try again.', 'Error', 'error'))
                    elseif ~ isempty(find(cellfun(@isempty, q_submissionList(q_counter:sum(q_numFiles(1:q)), 2)), 1))
                        waitfor(msgbox('At least one file does not have a name. Please try again.', 'Error', 'error'))
                    else
                        waitfor(msgbox('At least one file has an illegal character in its name. Please try again.', 'Error', 'error'))
                    end
                    q_submissionList(q_counter:sum(q_numFiles(1:q)), 1:2) = [num2cell(q * ones(q_numFiles(q), 1)) inputdlg(prompt_fileNames(1:q_numFiles(q), q))];
                end
                q_counter = q_counter + q_numFiles(q);
            end
            if strcmp(q_text_sol, 'Yes')
                if contains(assignmentName, 'Homework')
                    q_submissionList = [{1, ['HW' assignmentName(end) '_textsolution.pdf'], []}; q_submissionList];
                elseif contains(assignmentName, 'Project')
                    q_submissionList = [{1, ['P' assignmentName(end) '_textsolution.pdf'], []}; q_submissionList];
                end
            end
            extStartInd = strfind(q_submissionList(:, 2), '.');
            for file_num = 1:size(q_submissionList, 1)
                fileName = q_submissionList{file_num, 2};
                fileExt = fileName(extStartInd{file_num} + 1:end);
                if strcmp(fileExt, 'm')
                    q_submissionList{file_num, 3} = questdlg(['Is ' fileName ' a MATLAB script or a MATLAB function?'], 'M File', 'MATLAB Script', 'MATLAB Function', 'MATLAB Function');
                elseif strcmp(fileExt, 'pdf')
                    if contains(fileName, 'solution')
                        q_submissionList{file_num, 3} = 'Text Solutions';
                    else
                        q_submissionList{file_num, 3} = 'Figure';
                    end
                elseif strcmp(fileExt, 'jpg') || strcmp(fileExt, 'jpeg') || strcmp(fileExt, 'png') || strcmp(fileExt, 'fig')
                    q_submissionList{file_num, 3} = 'Figure';
                end
            end
            save([assignmentName '\submissionList.mat'], 'q_submissionList')
        end
        cd(origDir)
    end
end
end