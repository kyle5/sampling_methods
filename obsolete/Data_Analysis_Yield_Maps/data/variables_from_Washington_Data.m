%clc

red_total_sections_per_row = 15;

red_total_cluster_thinned_rows = 10;
red_total_not_cluster_thinned_rows = 5;
red_total_rows = red_total_cluster_thinned_rows + red_total_not_cluster_thinned_rows;

[numbers_red_excel,txt_red_excel,raw_red] = xlsread('casc_apple_yield.xls', 'red_apple');

red_column_offset = 2;
red_row_offset = 2;

red_thinned_ground_counts = [];
red_thinned_pc_counts = [];
red_not_thinned_ground_counts = [];
red_not_thinned_pc_counts = [];

total_hand_count_red_thinned = 0;
total_hand_count_red_not_thinned = 0;

total_computer_count_red_thinned = 0;
total_computer_count_red_not_thinned = 0;

for row_in_orchard = 1:red_total_rows*2
    cur_row_count = [];
    col_in_excel = row_in_orchard+red_column_offset;
    row_type = txt_red_excel(7, col_in_excel);
    
    for cur_section = 1:red_total_sections_per_row
        row_in_excel = cur_section + red_row_offset;
        cur_section_add_on = numbers_red_excel(row_in_excel, col_in_excel);
        cur_row_count = [cur_row_count, cur_section_add_on];
    end
    if strcmp(row_type, 'gnd');
        if row_in_orchard/2 <= 10
            red_thinned_ground_counts = [red_thinned_ground_counts; cur_row_count];
            for i = 1:size(cur_row_count, 2)
                total_hand_count_red_thinned = total_hand_count_red_thinned + cur_row_count(1, i);
            end
        else
            red_not_thinned_ground_counts = [red_not_thinned_ground_counts; cur_row_count];
            for i = 1:size(cur_row_count, 2)
                total_hand_count_red_not_thinned = total_hand_count_red_not_thinned + cur_row_count(1, i);
            end

        end
    else
        if row_in_orchard/2 <= 10
            red_thinned_pc_counts = [red_thinned_pc_counts; cur_row_count];
            for i = 1:size(cur_row_count, 2)
                total_computer_count_red_thinned = total_computer_count_red_thinned + cur_row_count(1, i);
            end
        else
            red_not_thinned_pc_counts = [red_not_thinned_pc_counts; cur_row_count];
            for i = 1:size(cur_row_count, 2)
                total_computer_count_red_not_thinned = total_computer_count_red_not_thinned + cur_row_count(1, i);
            end
        end
    end
end

save('redAppleVariables.mat', 'total_hand_count_red_thinned', 'total_hand_count_red_not_thinned',...
    'total_computer_count_red_thinned', 'total_computer_count_red_not_thinned', 'red_thinned_ground_counts',...
    'red_not_thinned_ground_counts', 'red_thinned_pc_counts', 'red_not_thinned_pc_counts');

total_hand_count_green = 0;
total_computer_count_green = 0;

%Get data on green apples from excel file
green_total_sections = 16;
green_total_rows = 15;

[num_green,txt_green,raw_green] = xlsread('casc_apple_yield.xls', 'green_apple');

green_ground_counts = [];
green_pc_counts = [];

green_pc_count_row_offset = 9;
green_hand_count_row_offset = 36;
green_col_offset = 3;

for row_in_orchard = 1:green_total_rows
    cur_row_count_pc = [];
    col_in_excel = row_in_orchard+green_col_offset;

    %First get the data from the excel on the computer counts
    for section = 1:green_total_sections
        row_in_excel = section + green_pc_count_row_offset;
        cur_section_add_on = num_green(row_in_excel, col_in_excel);
        total_computer_count_green = total_computer_count_green + cur_section_add_on;
        cur_row_count_pc = [cur_row_count_pc, cur_section_add_on];
    end
    green_pc_counts = [green_pc_counts; cur_row_count_pc];
end
for row_in_orchard = 1:green_total_rows
    cur_row_count_hand = [];
    col_in_excel = row_in_orchard+green_col_offset;
    
    %Second get the data from the excel on the ground truth
    for section = 1:green_total_sections
        row_in_excel = section + green_hand_count_row_offset;
        cur_section_add_on = num_green(row_in_excel, col_in_excel);
        total_hand_count_green = total_hand_count_green + cur_section_add_on;
        cur_row_count_hand = [cur_row_count_hand, cur_section_add_on];
    end
    green_ground_counts = [green_ground_counts; cur_row_count_hand];
end
save('greenAppleVariables.mat', 'total_hand_count_green', 'total_computer_count_green', 'green_ground_counts', 'green_pc_counts');
