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
if [ -d build/ ]; then
	rm -R build
fi
mkdir -p build
cd build
../build.sh
popd
#
# go to the new farthest point optimization directory
pushd $new_farthest_point_dir
if [ -d build/ ]; then
	rm -R build
fi
mkdir -p build
cd build
../build.sh
popd
#

# C++ compile
cd "${top_level_dir}/"
if [ -d build/ ]; then
	rm -R build
fi
mkdir -p build
cd build

opencv_dir="/opt/ros/fuerte/"

include_args="-I${opencv_dir}/include/ -I. -I$top_level_dir/farthest_point_optimization -I$top_level_dir/farthest_point_stratified_yield_and_spatial/"

opencv_link_args="-L${opencv_dir}/lib/ -lopencv_core -lopencv_features2d -lopencv_imgproc -lopencv_highgui -lopencv_nonfree -lopencv_ml"

farthest_point_link_args="-L$top_level_dir/farthest_point_optimization/build/ -lget_points -L$top_level_dir/farthest_point_stratified_yield_and_spatial/build/ -lget_points_stratified_and_spatial"

cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core"

g++ ${include_args} -frounding-math -o main_call_farthest_point_libraries.exe ../main_call_farthest_point_libraries.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}
