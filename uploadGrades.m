function [] = uploadGrades()
% gradeAssignment: Automatically enters individual student folders and
% copies the contents of the graderComments.doc file, allowing graders to
% simply paste students' scores into the UVACollab grading system.

q_uploadGrades = questdlg('Would you like to upload grades to UVACollab?', '', 'Yes', 'No', 'No');
if strcmp(q_uploadGrades, 'Yes')
    origDir = pwd;
    assignmentsDir = struct2cell(dir('Assignments'))';
    studentsDir = struct2cell(dir('Students'))';
    studentsDir = studentsDir(3:end - 1, 1);
    q_assignment = listdlg('PromptString', 'Select an assignment.', 'SelectionMode', 'single', 'ListString', assignmentsDir(3:end, 1));
    assignmentName = assignmentsDir{2 + q_assignment};
    if ~ exist(['Assignments\' assignmentName '\gradeStatus.mat'], 'file')
        waitfor(msgbox(['No student has had their ' assignmentName ' submissions graded yet.']))
        error(['You cannot upload grades for ' assignmentName ' at this time.'])
    else
        load(['Assignments\' assignmentName '\gradeStatus.mat'], 'gradeStatus')
        if isempty(find(strcmp(gradeStatus(:, 2), 'Graded'), 1))
            waitfor(msgbox(['No student has had their ' assignmentName ' submissions graded yet.']))
            error(['You cannot upload grades for ' assignmentName ' at this time.'])
        end
    end
    if isempty(find(contains(gradeStatus(contains(gradeStatus(:, 3), 'Not Uploaded'), 2), 'Not Graded'), 1))
        word = actxserver('Word.Application');
        uploadedInd = find(~ contains(gradeStatus(:, 3), 'Not Uploaded'));
        uploadedStudents = gradeStatus(uploadedInd, 1);
        if ~ isempty(uploadedStudents)
            q_addUploadedStudents = questdlg('Would you like to reupload grades for any students?', '', 'Yes', 'No', 'No');
            if strcmp(q_addUploadedStudents, 'Yes')
                q_addUploadedStudentsSel = listdlg('PromptString', 'Choose student(s) to add.', 'ListString', uploadedStudents);
                gradeStatus(uploadedInd(q_addUploadedStudentsSel), 2) = {'Not Graded'};
                save(['Assignments\' assignmentName '\gradeStatus.mat'], 'gradeStatus')
            end
        end
        remainingStudentsInd = find(contains(gradeStatus(:, 3), 'Not Uploaded'));
        remainingStudentsInd = remainingStudentsInd(~ contains(gradeStatus(remainingStudentsInd, 2), 'Not Graded'));
        for studentLoop = 1:length(remainingStudentsInd)
            cd(['Students\' studentsDir{remainingStudentsInd(studentLoop)} '\' assignmentName])
            wdoc = word.Documents.Open([pwd '\graderComments.doc']);
            clipboard('copy', wdoc.Content.Text);
            wdoc.Close
            cd(origDir)
            q_uploadCheck = questdlg([studentsDir{remainingStudentsInd(studentLoop)} '''s scores have been saved to the clipboard. Press Done after entering grades on UVACollab or Cancel to abort.'], '', 'Done', 'Cancel', 'Cancel');
            if strcmp(q_uploadCheck, 'Done')
                gradeStatus{remainingStudentsInd(studentLoop), 3} = 'Uploaded';
                save([origDir '\Assignments\' assignmentName '\gradeStatus.mat'], 'gradeStatus')
            else
                error('You chose to abort the program.')
            end
        end
        word.Quit
    else
        waitfor(msgbox(['There are no pending grades to be uploaded for ' assignmentName '.']))
    end
end