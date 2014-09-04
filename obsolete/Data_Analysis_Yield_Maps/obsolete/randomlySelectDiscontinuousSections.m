function [ rand_sections_to_count ] = randomlySelectDiscontinuousSections( total_sections, number_of_sections_to_count_cur_percentage )
    rand_sections = randperm( total_sections );
    rand_sections_to_count  = rand_sections( 1:number_of_sections_to_count_cur_percentage );
end