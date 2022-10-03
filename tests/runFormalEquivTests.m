%% Runs Tests for Formal Functional Equivalence
clear
clc
runTestsDialogResult = questdlg('Would you like to run project tests?','Run Project Tests','Yes','No','No');
if strcmp(runTestsDialogResult,'Yes')
    disp("Running tests...")
    pause(3)
    runtests("formalEquivTests.m")
end