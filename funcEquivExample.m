clear
clc
%isFuncEqual = formalEquivalence("version1","version2") % should be
%not equal
isFuncEqual = formalEquivalence("version1","version3") % should be equal