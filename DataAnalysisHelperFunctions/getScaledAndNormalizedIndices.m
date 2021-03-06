function [ normalized_scaled_indices_x, normalized_scaled_indices_y ] = getScaledAndNormalizedIndices( columns_cur_map, rows_cur_map, scaling_factor_image )
     % Multiply by the scaling factor and add an extra row and column
     % This way none of the points are on the edge of the image
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;
     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     
     scaled_x_indices = 1:(columns_cur_map_scaled);
     scaled_y_indices = 1:(rows_cur_map_scaled);
     
     normalized_scaled_indices_x = scaled_x_indices / scaling_factor_image;
     normalized_scaled_indices_y = scaled_y_indices / scaling_factor_image;
end