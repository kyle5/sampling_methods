function [ row, col, z ] = getSelectedIndicesFromMatrix( input_Matrix, selected_indices )
    
    number_selected = size(selected_indices, 2);
    row = ones(number_selected, 1);
    col = ones(number_selected, 1);
    z = ones(number_selected, 1);
    
    for i = 1:number_selected
        cur_idx = selected_indices(i);
        [ cur_row, cur_col ] = ind2sub( size(input_Matrix), cur_idx );
        cur_z = input_Matrix( cur_row, cur_col );
        row(i, 1) = cur_row;
        col(i, 1) = cur_col;
        z(i, 1) = cur_z;
    end
    
end