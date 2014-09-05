opencv_dir="/opt/ros/fuerte/"
top_level_dir_relative="$(dirname $0)"
top_level_dir="$(realpath ${top_level_dir_relative})"
path_combined_original_root="${top_level_dir}/farthest_point_stratified_yield_and_spatial/"
path_combined_new_root="${top_level_dir}/farthest_point_optimization_combined_approach/"

pushd ${path_combined_new_root}
mkdir -p build
cd build
../build.sh
popd

mkdir -p build
cd build

include_args="-I${opencv_dir}/include/ -I${path_combined_original_root} -I${path_combined_new_root}"
opencv_link_args="-L${opencv_dir}/lib/ -lopencv_core -lopencv_features2d -lopencv_imgproc -lopencv_highgui -lopencv_nonfree -lopencv_ml"
farthest_point_link_args="-L${path_combined_new_root}/build/ -lget_points_combined_approach"
cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core"

mex ${include_args} LDFLAGS='$LDFLAGS'" -Wl,-rpath=${opencv_dir}/lib" ../mex_get_optimal_indices_globally.cpp ../mex_conversion_matlab_and_cpp.cpp ../convertOpenCVMatToMatlabMat.cpp ../convertMatlabMatToOpenCVMat.cpp ${opencv_link_args} ${farthest_point_link_args} ${cgal_link_args}
