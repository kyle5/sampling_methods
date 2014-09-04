function [ values_at_locations ] = getValuesAtLocations( z_values, x_values_sample, y_values_sample )
    number_of_values_sample = size(x_values_sample, 1);
    values_at_locations = ones(number_of_values_sample, 1);
    for i = 1:number_of_values_sample
        cur_x_idx = x_values_sample( i, 1 );
        cur_y_idx = y_values_sample( i, 1 );
        values_at_locations( i, 1 ) = z_values( cur_y_idx, cur_x_idx );
    end
end