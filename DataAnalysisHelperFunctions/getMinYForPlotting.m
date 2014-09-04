function [ min_y ] = getMinYForPlotting( all_values_matrix, regular_min )
    if numel(all_values_matrix) == 0
        min_y = regular_min;
        return;
    end
    min_val = min( all_values_matrix(:) );
    min_val_scaled = min_val * 1.2;
    min_y = min(min_val_scaled, regular_min);
end