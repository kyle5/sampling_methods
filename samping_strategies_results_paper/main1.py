import os
import math
class one_figure:
  def __init__( self, image1, image2, caption ):
    self.image1 = image1
    self.image2 = image2
    self.caption = caption
class one_image:
  def __init__( self, path_to_image, caption_for_image ):
    self.path_to_image = path_to_image
    self.caption_for_image = caption_for_image
def create_figures_side_by_side( one_figure_input ):
   print r"\begin{figure}[!h]"
   print r"\centering"
   print r"\begin{subfigure}[b]{0.4\textwidth}"
   print r"\includegraphics[width=\textwidth]{%s}" % one_figure_input.image1.path_to_image
   print r"\caption{%s}" % one_figure_input.image1.caption_for_image
   print r"\label{fig:gull}"
   print r"\end{subfigure}"
   print r"\begin{subfigure}[b]{0.4\textwidth}"
   print r"\includegraphics[width=\textwidth]{%s}" % one_figure_input.image2.path_to_image
   print r"\caption{%s}" % one_figure_input.image2.caption_for_image
   print r"\label{fig:mouse}"
   print r"\end{subfigure}"
   print r"\caption{%s}" % one_figure_input.caption
   print r"\label{fig:animals}"
   print r"\end{figure}"
class one_figure_and_one_image:
  def __init__( self, path_to_image, caption ):
    self.path_to_image = path_to_image
    self.caption = caption
def create_figure(one_figure_and_one_image_input):
   print r"\begin{figure}[!h]"
   print r"\centering"
   print r"\includegraphics[width=8cm,height=6cm]{%s}" % one_figure_and_one_image_input.path_to_image
   print r"\caption{%s}" % one_figure_and_one_image_input.caption
   print r"\label{Serie}"
   print r"\end{figure}"
section_sampling = ""
directory = "."
extension = ".png"
files = [file for file in os.listdir(directory) if file.lower().endswith(extension)]
print r"\section{ Stratified random sampling }"
print r"Stratified sampling focuses on breaking a sampling space up into different groups (or strata). For our purposes, we created strata that divided up the yield distribution. Each strata encompasses one section of the yield distribution (from high, to medium, to low levels of counts). Samples are selected from each level, to ensure that a representative sample is selected."
figure_temp = one_figure( one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Stratified_(Hand_+_Image)_r_sq_0_72.png", "Red Delicious" ), one_image( "grape/PN_Simulated/automatic/Pinot_Noir_Stratified_(Hand_+_Image)_r_sq_0_36.png", "Pinot Noir" ), "Stratified Sampling is modestly effective for all types of datasets" )
create_figures_side_by_side( figure_temp )
print r"\pagebreak"
print r"\section{ Spatial sampling }"
print r"The current spatial sampling method simply focuses on iteratively moving points to locations that are far away from all other points."
figure_temp = one_figure( one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Spatial_(Hand_+_Image)_r_sq_0_72.png", "Red Delicious" ), one_image( "apple/Granny_Smith_Simulated/automatic/Granny_Smith_Spatial_(Hand_+_Image)_r_sq_0_56.png", "Granny Smith" ), "Spatial sampling yields modest improvements for apple datasets" )
create_figures_side_by_side( figure_temp )
print r"\subsection{ Direct Extrapolation: No Sensor Data }"
print r"All of our sampling methods are based on a process that starts with initially sampling groundtruth data. In this section, the results show that simply extrapolating this groundtruth subsample measurement can gain accuracy that is greater than scaling the sensor data."
print r"For the apple datasets, it is seen that direct extrapolation is not effective."
print r"For the grape datasets, direct extrapolation of the groundtruth sample is very effective."
grape_linear_offset_figure = one_figure( one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Random_(Hand_Only)_r_sq_0_72.png", "Red Delicious Groundtruth Extrapolation" ), one_image( "grape/PS_Simulated/automatic/Petite_Syrah_Random_(Hand_Only)_r_sq_0_33.png", "Petite Syrah Groundtruth Extrapolation" ), "Direct extrapolation is ineffective for apple datasets and effective for grape datasets" )
create_figures_side_by_side( grape_linear_offset_figure )
print r"This phenomenon of direct extrapolation being more effective than any sampling method is explained by an analysis of using linear offset functions to map image estimates to yield estimates."
print r"\pagebreak"
print r"\section{ Sampling: Scaling Function from Linear Regression }"
print( "\n\n" )
print r"Instead of scaling with a scalar value, a linear scaling function can be obtained by doing linear regression on the subsample data collected. With the resulting function, after regression, sensor data can be mapped to predicted yield more accurately."
print( "\n\n" )
print r"A linear regression is seen to be effective for grape datasets."
print( "\n\n" )
grape_linear_offset_figure = one_figure( one_image( "grape/PS_Simulated/automatic/Petite_Syrah_Random:_Regression_(Hand_+_Image)_r_sq_0_33.png", "Petite Syrah" ), one_image( "grape/Chardonnay_2013_Simulated/automatic/Chardonnay_2013_Random:_Regression_(Hand_+_Image)_r_sq_0_50.png", "Chardonnay" ), "A linear regression operation to find an offset linear function is the most important factor to transferring grape image measurements to yield estimates" )
create_figures_side_by_side( grape_linear_offset_figure )
print r"A linear regression is seen to be less effective for apple datasets."
print( "\n\n" )
apple_linear_offset_figure = one_figure( one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Random:_Regression_(Hand_+_Image)_r_sq_0_72.png", "Red Delicious" ), one_image( "apple/Granny_Smith_Simulated/automatic/Granny_Smith_Random:_Regression_(Hand_+_Image)_r_sq_0_56.png", "Granny Smith" ), "Linear regression to obtain offset linear function: Apple datasets" )
create_figures_side_by_side( apple_linear_offset_figure )
print( "\n" )
print r"This suggests that there are some systematic differences between apple detection and grape detection. This is logical as the grape code includes features that the apple code does not, such as a clustering step in the grape algorithm."
print( "\n\n" )
print r"\pagebreak"
simulating_alg_performance_text = "The previous sections have displayed the results that we have seen by using an emphircal approach. In this emphirical approach, we assume that we have already collected all of the groundtruth data from all farm plots, as well as image data from all farm plots. We have noticed through this emphirical study that the groundtruth data is organized by a normal distribution. As well, our algorithm has consistent error rates, which can also be modelled by a normal distribution. This means that we can first simulate groundtruth data and then simulate our algorithm's expected performance by adding an error distribution to the simulated groundtruth data. Through this process of simulation, we can model our algorithm's expected performance to a high degree of accuracy."
print r"\section{ Section: Simulating algorithm performance }"
print( simulating_alg_performance_text )
print("\n")
print r"We can model the performance of only using groundtruth data:"
apple_groundtruth_extrapolation_simulation_figure = one_figure( one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Random_(Hand_Only)_r_sq_0_72.png", "Red Delicious: Empirical: Groundtruth Extrapolation" ), one_image( "apple/Red_Delicious_Simulated/automatic/Red_Delicious_Thinned_Simulated_(Hand_Only)_r_sq_0_72.png", "Red Delicious: Simulated: Groundtruth Extrapolation" ), "Simulation of groundtruth extrapolation" )
create_figures_side_by_side( apple_groundtruth_extrapolation_simulation_figure )
print("\n")
print r"We can also model the performance of our algorithm over grape datasets. In this model a linear function is used to transfer from hand to algorithm counts."
grape_linear_offset_figure = one_figure( one_image( "grape/PS_Simulated/automatic/Petite_Syrah_Random:_Regression_(Hand_+_Image)_r_sq_0_33.png", "Petite Syrah: Empirical" ), one_image( "grape/PS_Simulated/automatic/Petite_Syrah_Random:_Regression_(Hand_+_Image)_r_sq_0_33.png", "Petite Syrah: Simulated" ), "Simulated data yields almost identical results to empirical data." )
create_figures_side_by_side( grape_linear_offset_figure )
print("\n")
print r"\pagebreak"
print r"We can also model the performance of our algorithm over apple datasets. In this model a scaling factor is used to transfer from hand to algorithm counts."
apple_figure = one_figure_and_one_image( "apple/Granny_Smith_Simulated/automatic/Granny_Smith_Simulated:_Scaling_Factor:_(Hand_+_Image)_r_sq_0_56.png", "Simulated performance almost overlaps with empirical performance. Note: Empirical is labelled as 'random'" )
create_figure(apple_figure)
print("\n")
print r"\pagebreak"
print("\n")
decreasing_error_text = "Decreasing R-Squared values does not seem to have much effect on changing the error plots that are generated. This is explicable. If the errors can be represented by a normal distribution, then the errors act to balance each other out in our simulations. This means that unless R-squared values are very high, a decrease in performance is not estimated. This occurs as even when section by section error is at 20 percent, the overall error is not high because these section errors balance each other out."
print( decreasing_error_text )
print("\n")
grape_linear_offset_figure_2 = one_figure( one_image( "grape/Chardonnay_2013_r_squared/automatic/Chardonnay_2013_Simulated:_Regression_(Hand_+_Image)_r_sq_0_50.png", "Petite Syrah: R^2: 0.50" ), one_image( "grape/Chardonnay_2013_r_squared/automatic/Chardonnay_2013_Simulated:_Regression_(Hand_+_Image)_r_sq_0_93.png", "Petite Syrah: R^2: 0.93" ), "``Low'' R-squared values yield graphs that are indistinguishable from one another" )
create_figures_side_by_side( grape_linear_offset_figure_2 )
grape_linear_offset_figure_3 = one_figure( one_image( "grape/Chardonnay_2013_r_squared/automatic/Chardonnay_2013_Simulated:_Regression_(Hand_+_Image)_r_sq_0_97.png", "Petite Syrah: R^2: 0.97" ), one_image( "grape/Chardonnay_2013_r_squared/automatic/Chardonnay_2013_Simulated:_Regression_(Hand_+_Image)_r_sq_0_99.png", "Petite Syrah: R^2: 0.99" ), "Only higher R-squared values yield graphs with distinguishable differences from one another" )
create_figures_side_by_side( grape_linear_offset_figure_3 )
print("\n")
print("\n")
conclusion_text = "This document summarizes results found between July and August 2014, with regards to sampling methods in orchards and vineyards. This includes an analysis of sampling methods that revolve around a scaling factor: random sampling, stratified random sampling, and spatial sampling. In addition, this also includes an analysis of pure groundtruth extrapolation and the usage of a linear function instead of a scaling factor.\n\nThe main takeaway conclusions are different for apple and grape datasets.\n\nFor grape datasets, stratified and spatial sampling approaches only improve performance marginally. Improvements, instead, came from either using a linear function for scaling sensor data or directly extrapolating sensor data. In fact, directly extrapolating the groundtruth subsample yields similar accuracy as using a linear scaling function and any sampling method (stratified, spatial, random) for all 3 datasets. The message from these results is that 1.) a linear scaling function is necessary for mapping image estimates to yield estimates and 2.) the sensor data is not adding much signal currently, if an extrapolation of the groundtruth sample is as effective as using sensor measurements and the groundtruth sample.\n\nFor apple datasets, stratified and spatial sampling lead to small increases in performance that are marginal. A linear scaling function or direct extrapolation of groundtruth measurements did not lead to performance increases."
print("\n")
print r"\pagebreak"
print("\n")
print r"\pagebreak"
correlation_text = "Analyzing the correlation between ground counts and algorithm counts shows that there is a low correlation between ground counts and algorithm counts. A lack of correlation between the harvest monitor data and our estimates could be due to errors in the harvest monitor data. To analyze this, we attempted to smooth the sensor data over individual rows. In this approach, we tried to not smooth sensor data accross adjoint rows. With this approach, a low correlation score between ground counts and algorithm counts is still apparent."
print("\n")
print( correlation_text )
print("\n")
correlation_figure = one_figure( one_image( "correlation/correlation_btw_algorithm_and_ground_counts.png", "Correlation: 2 Meter Step" ), one_image( "correlation/correlation_btw_algorithm_and_ground_counts_wider_smoothing_area_only_over_rows.png", "Correlation: 50 Meter Step only over rows" ), "Correlation between Ground and Algorithm Counts" )
create_figures_side_by_side( correlation_figure )
print("\n")
print r"\pagebreak"
print("\n")
print r"\pagebreak"
print r"\section{ Conclusion }"
print( conclusion_text )
print("\n")

