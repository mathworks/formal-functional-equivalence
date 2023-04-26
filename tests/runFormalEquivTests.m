%% Runs Tests for Formal Functional Equivalence
clear
clc
runTestsDialogResult = questdlg('Would you like to run project tests?','Run Project Tests','Yes','No','No');
if strcmp(runTestsDialogResult,'Yes')
    f = msgbox(["Tests will commence momentarily and may take several minutes to complete.","Please ignore any windows that pop up until testing has completed.","Results will appear in the MATLAB Command Window."]);
    pause(6)
    close(f)
    clear f
    disp("Running tests...")
    runtests("formalEquivTests.m")
end
clear runTestsDialogResult