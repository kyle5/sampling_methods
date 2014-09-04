function [average_error] = computeAverageErrorBetweenMatrices(incorrect, correct, index, absoluteValueErrorCalculation )
    if correct == 0
        disp('divide by zero error');
        average_error = 1;
    elseif index < 1 || index > numel(incorrect)
        if absoluteValueErrorCalculation == 1
            dif = abs(incorrect - correct);
        else
            dif = incorrect - correct;
        end
        errors = dif./abs(correct);
        average_error = mean2(errors);
    else
        if absoluteValueErrorCalculation == 1
            dif = abs(incorrect(index) - correct(index));
        else
            dif = incorrect(index) - correct(index);
            
        end
        average_error = dif/abs(correct(index));
    end
end