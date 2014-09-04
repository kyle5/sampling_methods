function [ error ] = computeError( incorrect_number, correct_number )
    difference = abs(incorrect_number - correct_number);
    error = difference/correct_number;
end

