# Formal Functional Equivalence

[Functional equivalence testing](https://www.mathworks.com/help/sltest/ug/test-two-simulations-for-equivalence.html) is a workflow which involves simulating two models, or a model and its generated code, and ensuring their outputs are equivalent. This is a common workflow in standards such as ISO26262, however this technique does not formally prove functional equivalence in all cases.

This project provides a set of utilities for performing "formal functional equivalence," which is a static analysis-based technique to prove that two Simulink&reg; models are functionally equivalent. These utilities use Property Proving in Simulink Design Verifier&trade;. If the two models are not formally functionally equivalent, Simulink Design Verifier will generate a counterexample for debugging.

Consider using formal functional equivalence when refactoring a model to improve its maintainability, standards compliance, clarity, code generation performance, or for other considerations, while maintaining the expected behavior.

## Get Started
To Run:
1. Open [Formal_functional_equivalence.prj](https://github.com/mathworks/formal-functional-equivalence/blob/master/Formal_functional_equivalence.prj) in MATLAB&reg;. 
2. Run [funcEquivExample.m](https://github.com/mathworks/formal-functional-equivalence/blob/master/funcEquivExample.m) to see an example

## MathWorks Products
Requires MATLAB&reg; release R2022a or newer
* [MATLAB&reg;](https://www.mathworks.com/products/matlab.html)
* [Simulink&reg;](https://www.mathworks.com/products/simulink.html)
* [Simulink Check&trade;](https://www.mathworks.com/products/simulink-check.html)
* [Simulink Test&trade;](https://www.mathworks.com/products/simulink-test.html)
* [Simulink Coverage&trade;](https://www.mathworks.com/products/simulink-coverage.html)
* [Simulink Design Verifier](https://www.mathworks.com/products/simulink-design-verifier.html)

## License
The license for  is available in the [license.txt](https://github.com/mathworks/formal-functional-equivalence/blob/master/license.txt) file in this repository.


Copyright 2022 The MathWorks, Inc.
