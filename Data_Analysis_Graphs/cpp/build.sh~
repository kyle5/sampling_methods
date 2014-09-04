#!/bin/bash

set -e
set -u

opencv_version_number="2.4.8"

top_level_dir_relative="$(dirname $0)"
top_level_dir="$(realpath ${top_level_dir_relative})"

# create both of the farthest point build directories
echo "top_level_dir: $top_level_dir"

original_farthest_point_dir=$top_level_dir/farthest_point_optimization
new_farthest_point_dir=$top_level_dir/farthest_point_stratified_yield_and_spatial
# go to the original farthest point optimization directory
pushd $original_farthest_point_dir
rm -R build
mkdir -p build
cd build
../build.sh
popd
#
# go to the new farthest point optimization directory
pushd $new_farthest_point_dir
rm -R build
mkdir -p build
cd build
../build.sh
popd
#

# C++ compile
cd "${top_level_dir}/"
mkdir -p build
cd build

opencv_dir="/opt/ros/fuerte/"

g++ -fPIC --shared -I. -I/opt/ros/fuerte/include/ -o libcompute_algorithm_error.so ../computeAlgorithmEstimateErrorValues.cpp ../setup_section_indices.cpp ../setup_counts_from_sections.cpp ../compute_error_helpers.cpp ../get_averages.cpp

mex_args="-I${opencv_dir}/include/ -L${opencv_dir}/lib/ -lopencv_core -lopencv_features2d -lopencv_imgproc -lopencv_highgui -lopencv_nonfree -lopencv_ml -L. -lcompute_algorithm_error -I."

include_args="-I${opencv_dir}/include/ -I. -I${top_level_dir}/farthest_point_optimization -I${top_level_dir}/farthest_point_stratified_yield_and_spatial/"
opencv_link_args="-L${opencv_dir}/lib/ -lopencv_core -lopencv_features2d -lopencv_imgproc -lopencv_highgui -lopencv_nonfree -lopencv_ml"
farthest_point_link_args="-L${top_level_dir}/farthest_point_optimization/build/ -lget_points -L${top_level_dir}/farthest_point_stratified_yield_and_spatial/build/ -lget_points_stratified_and_spatial"
cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core"

mex ${mex_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib" ../mexErrorValuesComputation.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}

cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core"
mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib"   ../mex_get_optimal_sampling_locations_one_sample.cpp ../mex_conversion_matlab_and_cpp.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}

mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib" ../mex_adjust_optimal_indices.cpp ../mex_conversion_matlab_and_cpp.cpp ../create_adjusted_indices.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}
