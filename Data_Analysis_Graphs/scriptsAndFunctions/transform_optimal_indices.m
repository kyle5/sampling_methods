function [optimal_sampling_indices_true] = transform_optimal_indices( optimal_sampling_indices, cur_ground_counts )
  %
  s_cur_ground_counts = size( cur_ground_counts );
  optimal_sampling_indices_actual = cell(size(optimal_sampling_indices));
  optimal_sampling_indices_true = cell(size(optimal_sampling_indices));
  for j = 1:numel( optimal_sampling_indices )
    cur_counts_indices = optimal_sampling_indices{j};

    % Check the organization of these indices: N*2 or  2*N
    keyboard;
    cur_adjusted = ceil( cur_counts_indices .*  repmat( fliplr( s_cur_ground_counts ), [ size(cur_counts_indices, 1), 1] ) );
    optimal_sampling_indices_actual{j} = cur_adjusted;
    optimal_sampling_indices_true{j} = sub2ind( s_cur_ground_counts, cur_adjusted(:, 2), cur_adjusted(:, 1) );
  end
end