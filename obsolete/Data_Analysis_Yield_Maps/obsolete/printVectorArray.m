function [ output_args ] = printVectorArray( array_one )
    for i = 1:size(array_one, 1)
        disp(array_one(i, 1));
    end
    output_args = 1;
end

