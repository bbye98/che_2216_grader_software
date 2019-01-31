function [] = gradeAssignment()
% gradeAssignment: Checks to see if the user would like to grade an
% assignment. Opens all of the submitted files matching those required for
% the assignment and prompts the user for the number of points to award and
% comments for any deducted points.

q_gradeAssignment = questdlg('Would you like to grade an assignment?', '', 'Yes', 'No', 'No');
originalDirectory = pwd;
if strcmp(q_gradeAssignment, 'Yes')
    assignmentsDir = struct2cell(dir('Assignments'))';
    studentsDir = struct2cell(dir('Students'))';
    studentsDir = studentsDir(3:end - 1, 1);
    q_assignment = listdlg('PromptString', 'Select an assignment to grade.', 'SelectionMode', 'single', 'ListString', assignmentsDir(3:end, 1));
    assignmentName = assignmentsDir{2 + q_assignment};
    load('Students\gradebook.mat', 'gradebook')
    load(['Assignments\' assignmentName '\numParts.mat'], 'q_numParts')
    load(['Assignments\' assignmentName '\pointValues.mat'], 'q_pointValues')
    load(['Assignments\' assignmentName '\submissionList.mat'], 'q_submissionList')
    gradebookCol = find(contains(gradebook(1, :), assignmentName), 1);
    if ~ exist(['Assignments\' assignmentName '\gradeStatus.mat'], 'file')
        gradeStatus = [studentsDir cell(size(studentsDir, 1), 1)];
        gradeStatus(cellfun(@isempty, gradebook(2:end, gradebookCol)), 2) = {'Not Graded'};
        save(['Assignments\' assignmentName '\gradeStatus.mat'], 'gradeStatus')
    else
        load(['Assignments\' assignmentName '\gradeStatus.mat'], 'gradeStatus')
    end
    gradedStudents = gradeStatus(~ contains(gradeStatus(:, 2), 'Not Graded'), 1);
    if ~ isempty(gradedStudents)
        q_addGradedStudents = questdlg('Would you like to revisit any work that has already been graded?', '', 'Yes', 'No', 'No');
        if strcmp(q_addGradedStudents, 'Yes')
            q_addGradedStudentsSel = listdlg('PromptString', 'Choose student(s) to add.', 'ListString', gradedStudents);
            gradeStatus(q_addGradedStudentsSel, 2) = {'Not Graded'};
        end
    end
    cd Students
    earnedPoints = 0 * q_pointValues;
    earnedComments = cell(size(q_pointValues, 1), size(q_pointValues, 2));
    alphabet = 'abcdefghijklmnopqrstuvwxyz';
    while ~ isempty(find(contains(gradeStatus(:, 2), 'Not Graded')))
        remainingStudentsInd = find(contains(gradeStatus(:, 2), 'Not Graded'));
        if ~ exist('curStudentInd', 'var')
            curStudentInd = 1;
        end
        gradeFlag = 1;
        studentName = studentsDir{remainingStudentsInd(curStudentInd)};
        cd([originalDirectory '\Students\' studentName '\' assignmentName])
        while gradeFlag
            folderDir = struct2cell(dir)';
            folderDir = folderDir(3:end, 1);
            uiwait(msgbox([{[studentName ' submitted the following files for ' assignmentName ':']}; ' '; folderDir; ' '; 'Press OK to continue.']));
            q_curStudent = questdlg(['You will be grading the work of ' studentsDir{remainingStudentsInd(curStudentInd)} '. Would you like to choose another student?'], 'Current Student', studentsDir{remainingStudentsInd(curStudentInd)}, 'Other', studentsDir{remainingStudentsInd(curStudentInd)});
            if strcmp(q_curStudent, 'Other')
                curStudentInd = listdlg('PromptString', 'Choose a student.', 'ListString', studentsDir(remainingStudentsInd), 'SelectionMode', 'single');
            else
                gradeFlag = 0;
            end
            studentName = studentsDir{remainingStudentsInd(curStudentInd)};
            cd([originalDirectory '\Students\' studentName '\' assignmentName])
        end
        graderComments = fopen('graderComments.doc', 'w');
        fprintf(graderComments, ['Student: ' studentName '\n']);
        fprintf(graderComments, ['Assignment: ' assignmentName '\n']);
        for cur_prob = 1:length(q_numParts)
            for a = find([q_submissionList{:, 1}] == cur_prob)
                if strcmp(q_submissionList{a, 3}, 'MATLAB Script')
                    if exist(q_submissionList{a, 2}, 'file') == 2
                        waitfor(msgbox(['Press OK to run ' studentName '''s MATLAB script ' q_submissionList{a, 2} '. Press Enter in the Command Window after reviewing the answers to continue.']))
                        try
                            run(q_submissionList{a, 2});
                        catch
                            warning(['There was an error that prevented ' q_submissionList{a, 2} ' from successfully running.'])
                        end
                        pause
                        close all
                    else
                        waitfor(msgbox([studentName '''s MATLAB script ' q_submissionList{a, 2} ' was not found.'], 'Error', 'error'))
                    end
                elseif strcmp(q_submissionList{a, 3}, 'MATLAB Function')
                    if exist(q_submissionList{a, 2}, 'file') == 2
                        waitfor(msgbox(['Press OK to open ' studentName '''s MATLAB script ' q_submissionList{a, 2} '. Press Enter in the Command Window after reviewing the answers to close the MATLAB function and continue.']))
                        open(q_submissionList{a, 2});
                        pause
                        edtSvc = com.mathworks.mlservices.MLEditorServices;
                        edtList = edtSvc.getEditorApplication.getOpenEditors.toArray;
                        [~, fname] = fileparts(char(edtList(end).getLongName.toString));
                        edt.(fname) = edtList(end);
                        edt.(q_submissionList{a, 2}(1:end - 2)).close
                    else
                        waitfor(msgbox([studentName '''s MATLAB function ' q_submissionList{a, 2} ' was not found.'], 'Error', 'error'))
                    end
                elseif strcmp(q_submissionList{a, 3}, 'Figure')
                    if exist(q_submissionList{a, 2}, 'file') == 2
                        waitfor(msgbox(['Press OK to open ' studentName '''s figure ' q_submissionList{a, 2} '. Press Enter in the Command Window after reviewing the figure to continue.']))
                        open(q_submissionList{a, 2});
                        pause
                    else
                        waitfor(msgbox([studentName '''s figure ' q_submissionList{a, 2} ' was not found.'], 'Error', 'error'))
                    end
                elseif strcmp(q_submissionList{a, 3}, 'Text Solutions')
                    if exist(q_submissionList{a, 2}, 'file') == 2
                        waitfor(msgbox(['Press OK to open ' studentName '''s text solutions. Press Enter in the Command Window after reviewing the document to continue.']))
                        open(q_submissionList{a, 2});
                        pause
                    else
                        waitfor(msgbox([studentName ' did not submit text solutions or they are in a misnamed file.'], 'Error', 'error'))
                    end
                end
            end
            for c = 1:q_numParts(cur_prob)
                if q_numParts(cur_prob) == 1
                    tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                else
                    tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) alphabet(c) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                end
                while isempty(tempScore) || tempScore < 0 || tempScore > q_pointValues(cur_prob, c) || strcmp(num2str(tempScore), 'NaN')
                    if isempty(tempScore) || tempScore < 0 || strcmp(num2str(tempScore), 'NaN')
                        waitfor(msgbox('You have entered text, an invalid value, or nothing. Please try again.', 'Error', 'error'))
                        if q_numParts(cur_prob) == 1
                            tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                        else
                            tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) alphabet(c) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                        end
                    end
                    if tempScore > q_pointValues(cur_prob, c)
                        waitfor(msgbox('You have entered a number exceeding the maximum possible value. Please try again.', 'Error', 'error'))
                        if q_numParts(cur_prob) == 1
                            tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                        else
                            tempScore = str2double(inputdlg({['How many points would you like to award ' studentName ' for his work for ' assignmentName ' Problem ' num2str(cur_prob) alphabet(c) '? (Max: ' num2str(q_pointValues(cur_prob, c)) ')']}));
                        end
                    end
                end
                earnedPoints(cur_prob, c) = tempScore;
                if q_numParts(cur_prob) == 1
                    earnedComments(cur_prob, c) = inputdlg({['Enter any comments for ' assignmentName ' Problem ' num2str(cur_prob) '.']});
                else
                    earnedComments(cur_prob, c) = inputdlg({['Enter any comments for ' assignmentName ' Problem ' num2str(cur_prob) alphabet(c) '.']});
                end
            end
            fprintf(graderComments, ['\nProblem ' num2str(cur_prob) ': ' num2str(nansum(earnedPoints(cur_prob, :))) '/' num2str(nansum(q_pointValues(cur_prob, :))) '\n']);
            for k = 1:q_numParts(cur_prob)
                if q_numParts(cur_prob) == 1
                    fprintf(graderComments, earnedComments{cur_prob, 1});
                    if size(char(earnedComments(cur_prob, k)), 2) > 0
                        fprintf(graderComments, '\n');
                    end
                else
                    fprintf(graderComments, ['\n\t' alphabet(k) ') ' num2str(earnedPoints(cur_prob, k)) '/' num2str(q_pointValues(cur_prob, k)) '\n\t   ']);
                    fprintf(graderComments, earnedComments{cur_prob, k});
                    if size(char(earnedComments(cur_prob, k)), 2) > 0
                        fprintf(graderComments, '\n');
                    end
                end
            end
        end
        fprintf(graderComments, ['\nTotal Score: ' num2str(sum(nansum(earnedPoints))) '/' num2str(sum(nansum(q_pointValues))) ' (' num2str(sum(nansum(earnedPoints)) / sum(nansum(q_pointValues)) * 100) '%%)\n']);
        fclose(graderComments);
        cd([originalDirectory '\Students'])
        gradebook{contains(gradebook(:, 1), studentName(1:strfind(studentName, '(') - 1)), gradebookCol} = sum(nansum(earnedPoints));
        save('gradebook.mat', 'gradebook')
        cd([originalDirectory '\Assignments\' assignmentName])
        gradeStatus{remainingStudentsInd(curStudentInd), 2} = 'Graded';
        save('gradeStatus.mat', 'gradeStatus')
        if remainingStudentsInd(curStudentInd) == remainingStudentsInd(end) && remainingStudentsInd(curStudentInd) ~= remainingStudentsInd(1)
            curStudentInd = 1;
        end
    end
end
cd(originalDirectory)
end