function [ ratio_each_section ] = computeRatioBetweenMatrices( numerator, denominator )
     % This program finds the scaling factor of computer counts to hand
     % counts over every section
     ratio_each_section = numerator./denominator;
end