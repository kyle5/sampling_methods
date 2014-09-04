function [ rand_sections_to_count ] = randomlySelectDiscontinuousSections( total_sections, number_of_sections_to_count_cur_percentage, valid_counts )
  rand_sections = randperm( total_sections );
  invalid_count_indices_numbers = find( valid_counts(:) == 0 );
  rand_sections_invalid = ismember( rand_sections, invalid_count_indices_numbers );
  rand_sections( rand_sections_invalid ) = [];
  rand_sections_to_count = rand_sections( 1:number_of_sections_to_count_cur_percentage );
end