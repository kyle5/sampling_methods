#ifndef __SETUP_SECTION_INDICES_H__
#define __SETUP_SECTION_INDICES_H__

#include <iostream>
#include <stdexcept>
#include <vector>
#include <string>
#include <utility>

#include <opencv2/core/core.hpp>

std::pair< std::vector<int>, std::vector<int> > setup_section_indices( std::vector<double> all_algorithm_counts_vec, std::string error_calc_type, int cur_sections_algorithm_counted, int cur_hand_sampled_number, int total_sections );

#endif
