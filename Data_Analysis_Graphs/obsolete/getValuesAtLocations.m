function [ values_at_locations ] = getValuesAtLocations( z_values, x_values_subsample, y_values_subsample, larger_image_used )

    number_of_values_subsample = size(x_values_subsample, 1);
    values_at_locations = ones(number_of_values_subsample, 1);
    for i = 1:number_of_values_subsample
        cur_x_idx = x_values_subsample(i, 1);
        cur_y_idx = y_values_subsample(i, 1);
        
        values_at_locations( i, 1 ) = z_values( cur_y_idx, cur_x_idx );
    end
end