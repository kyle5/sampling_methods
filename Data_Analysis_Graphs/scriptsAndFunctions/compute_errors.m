function [ mean_error_each_section, error_by_row, error_overall ] = compute_errors( cur_computer_counts_matrix, ground_counts, valid_counts )
  valid_counts = logical( valid_counts );
  error_each_section = abs(cur_computer_counts_matrix(valid_counts)-ground_counts(valid_counts))./ground_counts(valid_counts);
  mean_error_each_section = mean(error_each_section(:));
  
  cur_computer_counts_matrix( ~valid_counts ) = 0;
  ground_counts( ~valid_counts ) = 0;
  
  comp_counts_by_row = sum( cur_computer_counts_matrix, 1 );
  ground_counts_by_row = sum( ground_counts, 1 );
  cur_rand_row = ceil( randi(1, 1) * numel(ground_counts_by_row(:)) );
  error_by_row = computeAverageErrorBetweenMatrices( comp_counts_by_row, ground_counts_by_row, cur_rand_row, 1 );
  
  comp_counts_overall = sum(cur_computer_counts_matrix(valid_counts));
  ground_counts_overall = sum(ground_counts(valid_counts));
  error_overall = abs( ( comp_counts_overall - ground_counts_overall ) / ( ground_counts_overall ) );
end