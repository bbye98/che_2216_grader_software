# che_2216_grader_software
Software that automates most of the grading process for Professor Giri's CHE 2216: Modeling and Simulation in Chemical Engineering course

Features:
- Automatically creates individual student folders and a local gradebook from the class roster downloaded from UVACollab.
- Automatically extracts student-submitted files from the bulk_download.zip archive downloaded from UVACollab and moves them into individual student folders.
- Sets up homework assignments with number of parts, point values, and required file submissions for each question.
- Adds the ability to select which student to grade after showing the files that the current student submitted to skip over any students who completed the assignment with pair programming and did not submit any files.
- Automatically opens text solutions, figures, and MATLAB functions, and runs MATLAB scripts based on which question the user is grading.
- Automatically closes MATLAB functions after a question has been graded.
- Automatically generates graderComments.doc files based on points awarded and comments left by the grader and places them inside the individual student folders.
- Presents options and requests user inputs in easy-to-use user interfaces with instructions.
- Parses and checks all user inputs for validity.
- Catches errors and throws exceptions instead of stopping the program.
