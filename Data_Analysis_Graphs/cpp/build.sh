#!/bin/bash

set -e
set -u

opencv_version_number="2.4.8"

top_level_dir_relative="$(dirname $0)"
top_level_dir="$(realpath ${top_level_dir_relative})"

opencv_dir="/opt/ros/fuerte/"
top_level_dir_relative="$(dirname $0)"
top_level_dir="$(realpath ${top_level_dir_relative})"

# create both of the farthest point build directories
echo "top_level_dir: $top_level_dir"

path_original_farthest_point_dir="${top_level_dir}/farthest_point_optimization"
path_combined_original_root="${top_level_dir}/farthest_point_stratified_yield_and_spatial/"
path_combined_new_root="${top_level_dir}/farthest_point_optimization_combined_approach/"

# go to the original farthest point optimization directory
pushd $path_original_farthest_point_dir
if [ -d "build" ]; then
	rm -R build
fi
mkdir -p build
cd build
../build.sh
popd
#
# go to the new farthest point optimization directory
pushd $path_combined_original_root
if [ -d "build" ]; then
	rm -R build
fi
mkdir -p build
cd build
../build.sh
popd
#

pushd ${path_combined_new_root}
if [ -d "build" ]; then
	rm -R build
fi
mkdir -p build
cd build
../build.sh
popd

# C++ compile
cd "${top_level_dir}/"
if [ -d "build" ]; then
	rm -R build
fi
mkdir -p build
cd build

opencv_dir="/opt/ros/fuerte/"

#g++ -fPIC --shared -I. -I/opt/ros/fuerte/include/ -o libcompute_algorithm_error.so ../computeAlgorithmEstimateErrorValues.cpp ../setup_section_indices.cpp ../setup_counts_from_sections.cpp ../compute_error_helpers.cpp ../get_averages.cpp

include_args="-I${opencv_dir}/include/ -I. -I${path_combined_original_root} -I${path_combined_new_root} -I${path_original_farthest_point_dir}"
opencv_link_args="-L${opencv_dir}/lib/ -lopencv_core -lopencv_features2d -lopencv_imgproc -lopencv_highgui -lopencv_nonfree -lopencv_ml"
farthest_point_link_args="-L${top_level_dir}/farthest_point_optimization/build/ -lget_points -L${top_level_dir}/farthest_point_stratified_yield_and_spatial/build/ -lget_points_stratified_and_spatial -L${path_combined_new_root}/build/ -lget_points_combined_approach"
cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core"

mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib"   ../mex_get_optimal_sampling_locations_one_sample.cpp ../mex_conversion_matlab_and_cpp.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}

mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib" ../mex_adjust_optimal_indices.cpp ../mex_conversion_matlab_and_cpp.cpp ../create_adjusted_indices.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}

mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib" ../mex_get_optimal_indices_globally.cpp ../mex_conversion_matlab_and_cpp.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}
