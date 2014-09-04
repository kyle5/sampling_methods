function [ max_y ] = getMaxYForPlotting( all_values_matrix, regular_max )
    if numel(all_values_matrix) == 0
        max_y = regular_max;
        return;
    end
    max_val = max( all_values_matrix(:) );
    max_val_scaled = max_val * 1.2;
    max_y = max(max_val_scaled, regular_max);
end