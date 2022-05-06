function result = formalEquivalence(model1Name,model2Name)

%********************************************************************
%FILENAME:                  formalEquivalence.m
%
%Synopsis                   This function determines whether two models are
%                           functionally equivalent using formal verification.
%
%INPUT:                     model1Name: Name of first model
%                           model2name: Name of second model
%
%OUTPUT:                    result: Logical, true if models are formally
%functionally equivalent. Will return error if Simulink Design Verifier
%analysis encounters an error.

%********************************************************************
arguments
   model1Name  {mustBeA(model1Name,["string","char"])}
   model2Name {mustBeA(model2Name,["string","char"])}
end
bdclose all
load_system(model1Name)
load_system(model2Name)
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
[status,filenames] = sldvrun(mergedHarnessName,opts,true);
if status
    load(filenames.DataFile);
    result = ~strcmp(sldvData.Objectives.status,'Falsified');
else
    error("Analysis error.")
end
end