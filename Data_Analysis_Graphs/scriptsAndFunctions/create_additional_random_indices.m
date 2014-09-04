function [ all_sampled_sections ] = create_additional_random_indices( algorithm_counts, all_sampled_sections, random_sections_needed, valid_counts )
  non_overlapping_sections = 1:numel(algorithm_counts);
  invalid = false( size(algorithm_counts) );
  invalid(~valid_counts) = true;
  invalid(all_sampled_sections) = true;
  non_overlapping_sections( invalid ) = [];
  cur_random_indices = randperm( numel(non_overlapping_sections) );
  additional_random_sections = non_overlapping_sections( cur_random_indices( 1:random_sections_needed ) );
  all_sampled_sections = [ all_sampled_sections(:); additional_random_sections(:) ];
end