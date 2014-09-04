function [ tree_locations_x, tree_locations_y ] = getTreeLocationsInExpandedImage( columns_cur_map, rows_cur_map, scaling_factor_image )
    % This function finds the tree locations that are located in the image
    % that has been expanded for Kriging
    total_sections = rows_cur_map * columns_cur_map;
    
    tree_locations_x = ones(total_sections, 1);
    tree_locations_y = ones(total_sections, 1);

    tree_locations_i = 0;
    
    for j = 1:columns_cur_map
        for k = 1:rows_cur_map
            tree_locations_i = tree_locations_i + 1;
            tree_locations_x(tree_locations_i, 1) = j * scaling_factor_image;
            tree_locations_y(tree_locations_i, 1) = k * scaling_factor_image;
        end
    end
end

