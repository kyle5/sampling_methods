function [std_dev_sections, original_valid_idx] = get_std_dev_map( algorithm_counts, rand_sections_to_count )
  %
  % Temp: Change back
  index_mat_for_std = zeros(size(algorithm_counts));
  index_mat_for_std(rand_sections_to_count(:)) = rand_sections_to_count(:);
  [rows_cur_map, columns_cur_map] = size( index_mat_for_std );
  % Get optimal sections to sample with high std dev.
  std_dev_sections = zeros(size(rand_sections_to_count(:)));
  for ii = 1:numel(rand_sections_to_count(:))
    cur_rand_idx = rand_sections_to_count(ii);
    % Get the algorithm counts within a section around the current
    % index
    range = 3;
    [cur_row_idx, cur_col_idx] = ind2sub( size(index_mat_for_std), cur_rand_idx );
    top_left = [cur_row_idx-((range-1)/2), cur_col_idx-((range-1)/2)];
    bottom_right = [cur_row_idx+((range-1)/2), cur_col_idx+((range-1)/2)];
    if ( top_left(1) < 1 ); top_left(1) = 1; end
    if ( top_left(2) < 1 ); top_left(2) = 1; end
    if ( bottom_right(1) > rows_cur_map ); bottom_right(1) = rows_cur_map; end
    if ( bottom_right(2) > columns_cur_map ); bottom_right(2) = columns_cur_map; end
    counts_within_range = index_mat_for_std( top_left(1):bottom_right(1), top_left(2):bottom_right(2) );
    valid_counts = counts_within_range( counts_within_range > 0 );
    if numel( valid_counts ) < 5
      cur_std = nan;
    else
      cur_std = std( algorithm_counts( valid_counts(:) ) );
    end
    std_dev_sections( ii ) = cur_std;
  end
  std_dev_sections( isnan( std_dev_sections ) ) = -1;
  [v, idx] = sort( std_dev_sections );
  % Remove the NaN locations
  init_nan_locations = isnan(v);
  idx(init_nan_locations) = [];
  original_valid_idx = rand_sections_to_count( idx );
end