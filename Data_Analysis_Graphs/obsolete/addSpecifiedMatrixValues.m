function [ total_count ] = addSpecifiedMatrixValues( image_used, subsampled_sections )
    [rows_cur_map, columns_cur_map] = size(image_used);
    total_count = 0;
    temp_i = 0;
    
    for j = 1:rows_cur_map
        for k = 1:columns_cur_map

            current_place = ( j - 1 ) * ( columns_cur_map ) + k;

            if ismember(current_place, subsampled_sections)
                temp_i = temp_i + 1;
                current_count_one_section = image_used(j, k);
                total_count = total_count + current_count_one_section;
            end
        end
    end
end

