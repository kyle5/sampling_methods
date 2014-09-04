function [ error_matrix ] = computeErrorBetweenMatrices( incorrect_values, correct_values )
    difference = abs( incorrect_values - correct_values );
    error_matrix = computeRatioBetweenMatrices( difference, correct_values );
end

