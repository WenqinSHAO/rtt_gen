# 1/ number of stages for a given total length
# 2/ length distribution of each stage
# 3/ baseline RTT value for each stage
# 4/ additional deviation and spikes
# 5/ generative model for long during congestion

k.stage <- function(n) {
  # number of stages within n data points
  #
  # Args:
  #   n (int): the length the artificial traces
  #
  # Returns:
  #   int, number of stages the trace will contain
  #
  # Note:
  #   with larger n, the generated traces tend to have more stages
  #   there should as well be a reasonable up-bound for stage numbers
  #   we consider a shortest stage of 10 data points, the max k should be around floor(n/10)
  
}

len.stage <- function(n, k) {
  # given total length n and stage number k, generate the length of each stage
  #
  # Args:
  #  n (int): the length the artificial traces
  #  k (int): number of stages the trace will contain
  #
  # Returns:
  #  int vector of length k, the sum of which equals n
  #
  # Note:
  #   Possible patterns:
  #   1/ one or two dominant stages (paths); with several short living ones (first implement this case)
  #   2/ mixture of dominant stages (paths); and LB-like equivelant short living paths

}

baseline.stage <- function(k) {
  # for each stage, generate a baseline RTT
  #
  # Args:
  #  k (int): number of stages the trace will contain
  #
  # Returns:
  #   float vector of length k, each value represents the RTT baselien of that stage
  #
  # Note:
  #   the RTT difference among stages should be within a reasonable range
}

stage.trace <- function(len, baseline) {
  # given the length of each stage and the RTT baseline, assemble a trace contining only stages
  #
  # Args:
  #   len (vector of int): length of each stage, returns of len.stage
  #   baseline (vector of float): RTT baseline of each stage, returns of baseline.stage
  #
  # Returns:
  #   vector of float, n in length, containing k stages
}

noise.trace <- function(trace, len) {
  # given a trace with stages, add deviations or spikes due to transient congestion, system load, etc.
  # 
  # Args:
  #   trace (vector of float): the stage.trace
  #   len (vector of int): the length of each stage
  #
  # Returns:
  #   vector of float, n in length
  #
  # Note:
  #   each stage can have different model for noises, and can aslo depend on the baseline RTT value
  #   each single stage can even have several noise patterns over time
  #   at this stage we avoid too much complication, so RTT baselines are not considered
  #   spikes can be large but short living
  #   background noises could be relatively small but lasts for a while
  #   should these noises be considered change, in general no
  
}

congest.trace <- function(trace, len) {
  # given a trace, add long during congestion effect
  #
  # Args:
  #   trace (vector of float): the stage.trace
  #   len (vector of int): the length of each stage
  #
  # Returns:
  #   vector of float, n in length
  #
  # Note:
  #   length, location, amplitude of congestion should be generated
  
}