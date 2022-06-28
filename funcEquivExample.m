clear
clc
isFuncEqual1 = formalEquivalence("version1","version2") % should be not equivalent
isFuncEqual2 = formalEquivalence("version1","version3") % should be equal