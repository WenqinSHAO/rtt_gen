# 1/ number of stages for a given total length
# 2/ length of each stage
# 3/ baseline RTT value for each stage
# 4/ additional noises/deviations
# 5/ long during congestion

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
  #   we upbound the max k to floor(n/10)
  #
  r = rpois(1, floor(sqrt(n)/log(n)))
  return(min(r, floor(n/10)))
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
  if(k>1) {
    e <- floor(n/(k*(k-1))) # e ensures that there first k-1 stage don cosume the entire length
    len <- vector()
    for(i in seq_len(k-1)) {
      # 50 as lowerbound avoids very-short stages
      len <- append(len, floor(runif(1, 50, n/k+e)))
    }
    len <- append(len, n-sum(len))
    return(sample(len))
  } else {
    return(n)
  }
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
  baseline <- runif(1, 20, 200)
  if (k > 1){
    for (i in 2:k){
      baseline[i] <- baseline[i-1] + ((rgeom(1,0.5)+1) * runif(1, 3, 7) * sample(c(1, -1), 1))
    }
  }
  return(baseline)
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
  trace = vector()
  for (i in seq_len(length(len))) {
    trace <- append(trace, rep(baseline[i], len[i]))
  }
  return(trace)
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
  for (i in seq(length(len))) {
    idx = (sum(len[1:i])-len[i]) + seq(1, len[i], 1)
    trace[idx] <- trace[idx] + rexp(len[i], rate=runif(1, 0.5, 5))
  }
  return(trace)
}

congest.trace <- function(trace, len) {
  # given a trace, add long during congestion effect
  #
  # Args:
  #   trace (vector of float): the stage.trace
  #   len (vector of int): the length of each stage
  #
  # Returns:
  #   data.frame
  #     column 'trace': RTT ts, vector of float, n in length
  #     column 'cpt': idx when congestion happens, vecotr of int, 0,1 status
  #
  # Note:
  #   length, location, amplitude of congestion should be generated
  cpt <- rep(0, length(trace))
  for (i in seq(length(len))) {
    # alpha is prob of entering congestion
    alpha <- min(abs(rnorm(1, mean=0, sd=.005)), .01)
    # beta is proba of exiting congestion
    beta <- min(max(abs(rnorm(1, mean=0, sd=.1)), .01), .1)
    # a status machine of two status: in congestion, outside congestion
    cong.stat <- F # status
    cong.amplitude <- 0 # congestion amplitude
    cong.var.amplitude <- 0 # RTT variation within congestion
    idx = (sum(len[1:i])-len[i]) + seq(1, len[i], 1)
    for (j in idx){
      if (! cong.stat) {
        if (rbinom(1,1,alpha) == 1) {
          # enter congestion
          cong.stat <- T
          if ((j+1)<length(trace)){
            cpt[j+1] <- 1
          }
          cong.amplitude <- (rgeom(1,0.5)+1) * runif(1, 20, 50)
          # RTT vairation relates to the congestion amplitude but not totally
          cong.var.amplitude <- max(rnorm(1, mean = cong.amplitude, sd=10), 5) 
        }
      } else {
        trace[j] <- trace[j] + 
          max(0, (rpois(1,cong.var.amplitude^1.5) - cong.var.amplitude^1.5 + cong.amplitude))
        if (rbinom(1,1,beta) == 1) {
          # leaving congestion
          cong.stat <- F
          if ((j+1)<length(trace)){
            cpt[j+1] <- 1
          }
        }
      }
    }
  }
  return(data.frame(trace=trace, cpt=cpt))
}

rtt.gen <- function(n) {
  # generate random RTT time series
  #
  # Args:
  #   n (int): length of the RTT trace
  #
  # Returns:
  #   data.frame
  #     column 'trace': RTT ts, vector of float, n in length
  #     column 'cpt': idx when change happens, vecotr of int, 0, 1 status; 1 for change
  #
  k <- k.stage(n)
  len <- len.stage(n, k)
  stage <- stage.trace(len, baseline.stage(k))
  noise <- noise.trace(stage, len)
  congest <- congest.trace(noise, len)
  if (k > 1) {
    for (i in seq_len(k-1)) {
      congest$cpt[sum(len[1:i])+1] <- 1
    }
  }
  return(congest)
}
