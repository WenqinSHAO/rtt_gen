# What is it about?
Generate artificial Internet Round-Trip Time time series.

# How to use it?
An example usage is provided in [example.R](example.R).
With the __rtt.gen__ function provided in [rtt_gen.R](rtt_gen.R), one can
generate random RTT traces of a given length.
```R
# in the same folder of rtt_gen.R
source('rtt_gen.R')
# generates random RTT trace having 1000 data points
sample.rtt <- rtt.gen(1000)
```
__sample.rtt$trace__ contains the RTT trace, while in __sample.rtt$cpt__
indexes where a significant change happens to the generated RTT trace are flagged
to 1.

# How RTT trace is generated?
1. generate the number of stages;
2. generate the length for each stage;
3. generate the RTT baseline value for each stage;
4. add additional noises/deviation to the RTT baseline;
5. add relatively long during congestion.
