function [ x, y, z ] = getSelectedIndicesFromMatrix( input_Matrix, selected_indices )
    
    number_selected = size(selected_indices, 2);
    x = ones(number_selected, 1);
    y = ones(number_selected, 1);
    z = ones(number_selected, 1);
    
    for i = 1:number_selected
        cur_idx = selected_indices(i);
        [ cur_x, cur_y ] = ind2sub( size(input_Matrix), cur_idx );
        cur_z = input_Matrix( cur_x, cur_y );
        x(i, 1) = cur_x;
        y(i, 1) = cur_y;
        z(i, 1) = cur_z;
    end
    
end