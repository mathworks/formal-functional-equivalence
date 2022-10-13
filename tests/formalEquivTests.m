classdef formalEquivTests < matlab.unittest.TestCase
    properties
        Folder
        Project
    end
    
    methods(TestMethodSetup)
        % Setup for each test
        function setupTest(testCase)
        bdclose('all'); % close all Simulink models
        clc
        testCase.Folder = testCase.createTemporaryFolder();
        copyfile("version*",testCase.Folder)
        cd(testCase.Folder)
        end
    end

    methods(TestMethodTeardown)
        % Tear down for each test
        function teardownTest(testCase)
            bdclose('all')
            testCase.Project = matlab.project.rootProject;
            cd(testCase.Project.RootFolder)
        end
    end
    
    
    methods(Test)
        % Test methods
        
        % Verify that function accepts valid model names
        function verifyModelName(testCase)
            verifyError(testCase,@() formalEquivalence(modelName1,modelName2),'MATLAB:UndefinedFunction')
        end

        % Verify that function runs without warnings
        function verifyNoWarns(testCase)
            verifyWarningFree(testCase,@() formalEquivalence("version1","version3"))
        end

        % Verify two equivalent models
        function verifyEquivalent(testCase)
            isFuncEqual = formalEquivalence("version1","version3");
            testCase.verifyTrue(isFuncEqual)
        end
        
        % Verify two non-equivalent models
        function verifyNotEquivalent(testCase)
            isFuncEqual = formalEquivalence("version1","version2");
            testCase.verifyFalse(isFuncEqual)
            com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup('Web Browser') %#ok<JAPIMATHWORKS> % close MATLAB web browser
        end

    end
    
end