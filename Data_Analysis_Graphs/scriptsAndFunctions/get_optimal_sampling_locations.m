function [ all_optimal_sampling_indices_spatial, all_optimal_sampling_indices_spatial_and_stratified ] = get_optimal_sampling_locations( algorithm_counts, ground_counts, sampling_numbers_list, compute_spatial_and_stratified, valid_counts, loop_iterations )
  %
  visualize = 0;
  percent_actually_computed = 0.5;
  total_possible_indices = sum( valid_counts(:) );
  all_possible_indices = find( valid_counts == 1 );
  valid_counts = double( valid_counts );
  
  sections_required = 1;
  all_optimal_sampling_indices_spatial = cell( numel( sampling_numbers_list ), loop_iterations );
  all_optimal_sampling_indices_spatial_and_stratified = cell( numel( sampling_numbers_list ), sections_required );
  
%   error_decrease_requested_list should be a percentage of
%   previous_error_values value

  for i = 1:numel( sampling_numbers_list )
    cur_sampling_number = sampling_numbers_list(i);
    
    if cur_sampling_number > numel(algorithm_counts); disp('Impossible to obtain that many indices'); keyboard; end
    
    if sum(valid_counts(:)) < cur_sampling_number; keyboard; end
    % Get purely spatial locations
    
    for j = 1:loop_iterations
      if cur_sampling_number < percent_actually_computed * total_possible_indices
        if mod(j, 10) == 0; fprintf( '%.2f percent spatial indices computed\n', j/loop_iterations ); end
        
        stratified_and_spatial = 0;
        weight_spatial = 1;
        rand_seed = ceil(rand(1)*1000);
        ps_final_point_indices = {};
        [ ps_final_point_indices ] = mex_get_optimal_indices_globally( algorithm_counts, cur_sampling_number, stratified_and_spatial, weight_spatial, ground_counts, rand_seed, valid_counts );
%         ps_final_point_indices = [];
%         while isempty( ps_final_point_indices )
%           try
%             rand_seed = ceil(rand(1)*1000);
%             [ ps_final_point_indices ] = mex_get_optimal_sampling_locations_one_sample( algorithm_counts, cur_sampling_number, stratified_and_spatial, weight_spatial, ground_counts, rand_seed, valid_counts );
%           catch
%             disp('CGAL Error');
%           end
%         end
        
        zero_locations = valid_counts(ps_final_point_indices) == 0;
        if sum( zero_locations ) > 0;
          disp('ps_final_point_indices are wrong');
          keyboard;
        else
          fprintf( '%d ps_final_point_indices are correct\n', int64(numel(ps_final_point_indices)) );
        end
        if visualize == 1
          temp = zeros(size(valid_counts));
          temp(ps_final_point_indices) = 1;
          figure, imagesc(valid_counts);
          figure, imagesc(temp);
          keyboard;
        end
      else
        step_size = total_possible_indices / cur_sampling_number;
        indices_out_of_possible = 1:step_size:total_possible_indices;
        indices_out_of_possible = floor( indices_out_of_possible );
        ps_final_point_indices = all_possible_indices( indices_out_of_possible );
      end
      disp('after mex function call');

      edge_buffer = 0;
      [ps_rounded_y_matlab, ps_rounded_x_matlab] = ind2sub( size(algorithm_counts), ps_final_point_indices(:) );
      invalid = ps_rounded_x_matlab <= edge_buffer | ps_rounded_x_matlab >= (size(algorithm_counts, 2)+1)-edge_buffer | ps_rounded_y_matlab <= edge_buffer | ps_rounded_y_matlab >= (size(algorithm_counts, 1)+1)-edge_buffer;

      [ ps_final_point_indices ] = create_random_indices( ps_final_point_indices, invalid, algorithm_counts, cur_sampling_number, valid_counts );
      all_optimal_sampling_indices_spatial{i, j} = ps_final_point_indices;
    end
    
    finished = 0;
    iterations_taken = 0;
    if compute_spatial_and_stratified == 0 || cur_sampling_number > ( percent_actually_computed * total_possible_indices ) % If over 50% sampled, just use the spatial indices for efficiency
      final_point_indices = ps_final_point_indices;
      [all_optimal_sampling_indices_spatial_and_stratified{ i, :}] = deal(final_point_indices);
      finished = sections_required;
    end
    
    while finished < sections_required && compute_spatial_and_stratified == 1
      iterations_taken = iterations_taken + 1;
      if mod(iterations_taken, 10) == 0
        fprintf( 'iterations_taken: %d\n', iterations_taken );
      end
      stratified_and_spatial = 1;
      weight_spatial = 0.8;
      disp('before algorithm count location calculation');
      [ final_point_indices ] = mex_get_optimal_sampling_locations_one_sample( algorithm_counts, cur_sampling_number, stratified_and_spatial, weight_spatial, ground_counts, i, valid_counts );
      
      zero_locations = valid_counts(final_point_indices) == 0;
      if sum( zero_locations ) > 0;
        disp('final_point_indices are wrong');
      else
        fprintf( '%d final_point_indices are correct\n', int64(numel(final_point_indices)) );
      end
      if visualize == 1
        temp = zeros(size(valid_counts));
        temp(final_point_indices) = 1;
        figure, imagesc(valid_counts);
        figure, imagesc(temp);
        keyboard;
      end
      invalid = final_point_indices < 1 | final_point_indices > numel(algorithm_counts);
      if sum( invalid(:) ) > 0; keyboard; end
      [ final_point_indices ] = create_random_indices( final_point_indices, invalid, algorithm_counts, cur_sampling_number, valid_counts );
      
      finished = finished + 1;
      all_optimal_sampling_indices_spatial_and_stratified{ i, finished } = [ final_point_indices ];
      disp('found one!');
      pause(1);
    end
  end
end