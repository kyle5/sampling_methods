function [ X, Y ] = getAllXAndYValuesInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_image )
     % Multiply by the scaling factor and add an extra row and column
     % This way none of the points are on the edge of the image
     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;

     % X and Y will be used with every instance of the kriging() function
     [X,Y] = meshgrid(1:rows_cur_map_scaled, 1:columns_cur_map_scaled);
end

