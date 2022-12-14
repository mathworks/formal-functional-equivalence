function isFuncEquiv = formalEquivalence(model1Name,model2Name)

%********************************************************************
%FILENAME:                  formalEquivalence.m
%
%Synopsis                   This function determines whether two models are
%                           functionally equivalent using formal verification.
%
%INPUT:                     model1Name: Name of first model
%                           model2name: Name of second model
%
%OUTPUT:                    isFuncEquiv: Logical, true if models are formally
%functionally equivalent. Will return error if Simulink Design Verifier
%analysis encounters an error.

%********************************************************************
arguments
   model1Name  {mustBeA(model1Name,["string","char"])}
   model2Name {mustBeA(model2Name,["string","char"])}
end
warning('off','all') % disable warnings
bdclose all
load_system(model1Name)
load_system(model2Name)
%% Check for model compatibility with Simulink Design Verifier
model1_compatible = sldvcompat(model1Name);
if ~model1_compatible
    error(string(model1Name) + " is not compatible with Simulink Design Verifier")
end
model2_compatible = sldvcompat(model2Name);
if ~model2_compatible
   error(string(model2Name) + " is not compatible with Simulink Design Verifier")
end
%% Run formal functional equivalence
model1HarnessName = model1Name + "_harness";
harnessExists = ~isempty(sltest.harness.find(model1Name,'Name',model1HarnessName));
if harnessExists
    sltest.harness.delete(model1Name,model1HarnessName)
end
sltest.harness.create(model1Name,'Name',model1HarnessName,'SaveExternally',true);
updateHMdl(char(model1HarnessName),char(model2Name))
mergedHarnessName = model1HarnessName + "_mergedH";
opts = sldvoptions;
opts.Mode = 'PropertyProving';
opts.ProvingStrategy = 'FindViolation';
opts.MaxViolationSteps = 99;
[status,filenames] = sldvrun(mergedHarnessName,opts);
if status
    load(filenames.DataFile);
    isFuncEquiv = ~strcmp(sldvData.Objectives.status,'Falsified');
    if isFuncEquiv % try with ProvingStrategy set to 'Prove' as additional check
        opts.ProvingStrategy = 'Prove';
        [status,filenames] = sldvrun(mergedHarnessName,opts);
        if status
            load(filenames.DataFile);
            isFuncEquiv = ~strcmp(sldvData.Objectives.status,'Falsified');
        else
            error("Analysis error.")
        end
    end
else
    error("Analysis error.")
end
if ~isFuncEquiv % Load results for debugging
    sldvloadresults(mergedHarnessName,filenames.DataFile);
    sldvhighlight
    sldvreport(filenames.DataFile)
end
bdclose(mergedHarnessName)
warning('on','all') % re-enable warnings
end