classdef formalEquivTests < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
        function setupTest(testCase)
        bdclose('all'); % close all Simulink models
        clc
        end
    end

    methods(TestMethodTeardown)
        % Tear down for each test
        function teardownTest(testCase)
            if exist('sldv_covoutput','dir')
                rmdir('sldv_covoutput','s')
            end
            if exist('rtwgen_tlc','dir') % if this exists, then the rest should
                rmdir('rtwgen_tlc') % should be empty
                rmdir('sldv_output','s')
                rmdir('slprj','s')
                bdclose('all'); % close all Simulink models
                delete('version1_harness.slx')
                delete('version1_harness_mergedH.slx')
                delete('version1_harness_mergedH.slxc')
                delete('version1_harnessInfo.xml')
            end
        end
    end
    
    methods(Test)
        % Test methods
        
        % Verify that function accepts valid model names
        function verifyModelName(testCase)
            verifyError(testCase,@() formalEquivalence(modelName1,modelName2),'MATLAB:UndefinedFunction')
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
        end

        % Verify that function runs without warnings
        function verifyNoWarns(testCase)
            verifyWarningFree(testCase,@() formalEquivalence("version1","version3"))
        end
    end
    
end