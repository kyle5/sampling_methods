plotUnscaledComputerError( cur_all_computer_mean_errors, cur_dataset_id, parameters );

% Kyle: TODO: Test tomorrow
if calculate_error_hand_smoothed == 1
  cur_all_hand_mean_errors_smoothed = getMeanErrorsHandCountSmoothed( cur_ground_counts, cur_total_hand_count, parameters );
  save(mat_file_name_hand_smoothed, 'cur_all_hand_mean_errors_smoothed');
else
  load(mat_file_name_hand_smoothed);
end

% Kyle: TODO: Test tomorrow
if calculate_error_hand == 1
  [ cur_all_hand_mean_errors, cur_std_dev_hand_errors] = getMeanErrorsHandCountPercentages(cur_ground_counts, computeKriging, computeStdDev, cur_valid_counts, parameters );
  save(mat_file_name_hand, 'cur_all_hand_mean_errors', 'cur_std_dev_hand_errors');
else
  load(mat_file_name_hand);
end

% Get the below 3 methods finished tomorrow
if plot_hand_error == 1
  plotHandCountErrorGraph(cur_all_hand_mean_errors_smoothed, cur_dataset_id, parameters);
end

if plot_hand_computer_count_error == 1
  % This shows the comparison of hand and computer count errors at every
  % percentage level sampled
  plotComparisonHandAndComputerCount( cur_all_hand_mean_errors, cur_all_computer_mean_errors,...
      percentages_to_check, cur_dataset_id, comp_error_direct_extrapolation_discontinuous, type_of_error_to_show_hand );
end
if plot_percent_improvement_hand_to_computer_count == 1
  plotPercentImprovement(cur_all_hand_mean_errors, cur_all_computer_mean_errors, percentages_to_check, cur_dataset_id, type_of_error_to_show_computer, type_of_error_to_show_hand, total_sections );
end
% All of these graphs show comparisons for the error values of
% different types of computer counts
if plot_hand_error_type_comparison == 1
  plotComparisonOfHandCountError( cur_all_hand_mean_errors, cur_dataset_id, percentages_to_check, total_sections, show_continuous_block_data_false, percentage_index_to_use );
  plotComparisonOfHandCountError( cur_all_hand_mean_errors, cur_dataset_id, percentages_to_check, total_sections, show_continuous_block_data_true, percentage_index_to_use );
end
if plot_hand_and_computer_error_type_comparison == 1
  plotTypeOfErrorComparisonHandAndComputerCounts( cur_all_hand_mean_errors, cur_all_computer_mean_errors, percentages_to_check, cur_dataset_id, show_continuous_block_data_false, percentage_index_to_use );
  plotTypeOfErrorComparisonHandAndComputerCounts( cur_all_hand_mean_errors, cur_all_computer_mean_errors, percentages_to_check, cur_dataset_id, show_continuous_block_data_true, percentage_index_to_use );
end
if plot_percent_improvement_hand_to_computer_error_type_comparison == 1
  plotPercentImprovementComparison( cur_all_hand_mean_errors, cur_all_computer_mean_errors, percentages_to_check, cur_dataset_id, show_continuous_block_data_false, percentage_index_to_use );
  plotPercentImprovementComparison( cur_all_hand_mean_errors, cur_all_computer_mean_errors, percentages_to_check, cur_dataset_id, show_continuous_block_data_true, percentage_index_to_use );
end
% This section displays a comparison between sections sampled
% continuously (in groups) and sections sampled discontinuously
if plot_cont_and_discont_comparison == 1
  plotComputerCountComparisonBlockAndDiscontinuous( cur_all_computer_mean_errors, total_sections,...
      percentages_to_check, cur_dataset_id, type_of_error_comp_continuous, type_of_error_comp_discontinuous )
  plotHandCountComparisonBlockAndDiscontinuous( cur_all_hand_mean_errors, total_sections,...
      percentages_to_check, cur_dataset_id, type_of_error_hand_continuous, type_of_error_hand_discontinuous )
end
% This section displays the standard deviation of the error values
% First, for a comparison between kriging and direct extrapolation
if computeStdDev == 0 && (plot_std_dev_comp_error_one_type_of_error == 1 || plot_std_dev_hand_error_one_type_of_error == 1)
  disp('Turn computeStdDev to 1 in the flags section to show std deviation graphs');
elseif plot_std_dev_hand_error_single_percentage_hand_counted == 1 && plot_std_dev_comp_error_single_percentage_hand_counted == 1
  plotStdDevMultipleTypesHandAndCompError(cur_std_dev_computer_errors, cur_std_dev_hand_errors, cur_dataset_id, percentages_to_check, show_continuous_block_data_false, percentage_index_to_use );
elseif plot_std_dev_hand_error_single_percentage_hand_counted == 1
  plotStdDevMultipleTypesHandError(cur_std_dev_hand_errors, cur_dataset_id, percentages_to_check, show_continuous_block_data_false, percentage_index_to_use );
elseif plot_std_dev_comp_error_single_percentage_hand_counted == 1
  plotStdDevMultipleTypesCompError(cur_std_dev_computer_errors, cur_dataset_id, percentages_to_check, show_continuous_block_data_false, percentage_index_to_use );
end

% Second, for the errors of one type of computer counting the apples at different
% percentages of hand counts
if computeStdDev == 0 && (plot_std_dev_comp_error_one_type_of_error == 1 || plot_std_dev_hand_error_one_type_of_error == 1)
  disp('Turn computeStdDev to 1 in the flags section to show std deviation graphs');
elseif plot_std_dev_comp_error_one_type_of_error == 1 && plot_std_dev_hand_error_one_type_of_error == 1
  plotComparisonStdDevSingleTypeHandAndCompError( cur_std_dev_computer_errors, cur_std_dev_hand_errors, cur_dataset_id, percentages_to_check, type_of_error_to_show_computer, type_of_error_to_show_hand );
elseif plot_std_dev_hand_error_one_type_of_error == 1
  plotStdDevSingleTypeHandError( cur_std_dev_hand_errors, cur_dataset_id, percentages_to_check, type_of_error_to_show_hand  );
elseif plot_std_dev_comp_error_one_type_of_error == 1
  plotStdDevSingleTypeCompError( cur_std_dev_computer_errors, cur_dataset_id, percentages_to_check, type_of_error_to_show_computer );
end