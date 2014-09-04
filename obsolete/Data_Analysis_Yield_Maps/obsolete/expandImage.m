function [ input_x, input_y, input_z ] = expandImage( image_used, rand_sections_to_count, scaling_factor_image )
     % Perhaps a compute percentages for computer counts and a compute
     % percentages for hand counts also
     
     number_of_sections_to_count_cur_percentage = size(rand_sections_to_count, 1);
     input_x = ones(number_of_sections_to_count_cur_percentage, 1);
     input_y = ones(number_of_sections_to_count_cur_percentage, 1);
     input_z = ones(number_of_sections_to_count_cur_percentage, 1);
     
     % Easier to use index for indexing computer counts
     temp_i = 0;
     
     [ rows_cur_map, columns_cur_map ] = size( image_used );
     % Get values in expanded image
     for j = 1:rows_cur_map
        for k = 1:columns_cur_map
            
            current_place = ( j - 1 ) * ( columns_cur_map ) + k;
            
            if ismember(current_place, rand_sections_to_count)
                temp_i = temp_i + 1;
                current_count_one_section = image_used(j, k);
                
                input_x(temp_i, 1) = j * scaling_factor_image;
                input_y(temp_i, 1) = k * scaling_factor_image;
                input_z(temp_i, 1) = current_count_one_section;
            end
        end
     end
end