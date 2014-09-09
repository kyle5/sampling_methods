#ifndef __SETUP_COUNTS_FROM_SECTIONS_H__
#define __SETUP_COUNTS_FROM_SECTIONS_H__

#include <utility>
#include <vector>
#include <opencv2/core/core.hpp>

std::pair< std::vector<int>, std::vector<int> > setup_counts_from_sections( cv::Mat algorithm_counts_mat, cv::Mat groundtruth_counts_mat, std::pair< std::vector<int>, std::vector<int> > indices_ground_and_algorithm );

#endif
