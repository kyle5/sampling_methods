clc
close all

load redAppleVariables.mat
load greenAppleVariables.mat

percentages_to_check = [ 100, 50, 25, 10 ];

%% Flags
flag_red_thinned = 0;
flag_red_not_thinned = 0;
flag_red_overall = 0;
flag_green = 1;

global loop_iterations;
loop_iterations = 10000;

loop_iterations_string = num2str(loop_iterations);

%% Green

if flag_green == 1
    mat_file_name_computer = ['all_computer_mean_errors_green_', loop_iterations_string , '.mat'];
    mat_file_name_hand = ['all_hand_mean_errors_green_', loop_iterations_string , '.mat'];

    figuresToShow(:,:,1) = green_ground_counts;
    figuresToShow(:,:,2) = green_pc_counts;

    showFiguresOfCountsUnsmoothed( figuresToShow );
    
    
    

    %{
    if calculate_error_computer == 1
        %Get the errors for computer counts
        all_computer_mean_errors_green = getMeanErrorsComputerCount(green_pc_counts, green_ground_counts,...
            total_hand_count_green, total_green_pc_count);
        save(mat_file_name_computer, 'all_computer_mean_errors_green');
    else
        load(mat_file_name_computer);
    end
    if calculate_error_hand == 1
        all_hand_mean_errors_green = getMeanErrorsHandCount(green_ground_counts, total_hand_count_green);
        save(mat_file_name_hand, 'all_hand_mean_errors_green');
    else
        load(mat_file_name_hand)
    end
    %}

    showFiguresOfErrors();

    figure, imagesc(all_hand_mean_errors_green);
    figure, imagesc(all_computer_mean_errors_green);
end