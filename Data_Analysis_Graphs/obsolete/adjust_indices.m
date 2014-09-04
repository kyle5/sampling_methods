% Kyle: TODO: Make seperate functions for each of these below
function adjusted_count_indices = adjust_indices( adjusted_count_indices, rows_cur_map, columns_cur_map, mat_idx_valid )
  %
  sz_cur = [rows_cur_map, columns_cur_map];
  for i = 1:numel(adjusted_count_indices)
    [row_cur, col_cur] = ind2sub( sz_cur, adjusted_count_indices(i) );
    if rand() > 0.33; continue; end
    for j = 1:2
      radius = 2;
      pt_ = round( [col_cur, row_cur] + [radius*rand()-radius/2, radius*rand()-radius/2] );
      if pt_(1) >= 1 && pt_(1) <= columns_cur_map && pt_(2) >= 1 && pt_(2) <= rows_cur_map
        new_idx = sub2ind( sz_cur, pt_(2), pt_(1) );
        if mat_idx_valid( new_idx ) == 0
          mat_idx_valid( adjusted_count_indices(i) ) = 0;
          adjusted_count_indices(i) = new_idx;
          mat_idx_valid( adjusted_count_indices(i) ) = 1;
          break;
        end
      end
    end
  end
end