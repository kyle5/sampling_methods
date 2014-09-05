# this will be a build script to make the new sampling object code
opencv_dir="/opt/ros/fuerte/"

g++ -shared -fPIC -I .. -I ../../farthest_point_stratified_yield_and_spatial/ -I${opencv_dir}/include/ -Wall -frounding-math -o libget_points_combined_approach.so ../../farthest_point_stratified_yield_and_spatial/get_rp_helper_functions.cpp ../sampling_object.cpp -L${opencv_dir}/lib/ -l opencv_core -l opencv_highgui
