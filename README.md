# Network-Coding-WSNs
## Select the best number and locations of encoding nodes by solving the mathematical model.

This code is an implementation for a mathematical model that is developed to determine the optimal number of encoding nodes, and their location, under certain failure scenarios. Besides reducing cost and improving reliability, sensor networks end up having a higher
performance in terms of delay because the overall number of network coding operations decreases; 


You can use different network sizes, I am using here 40 nodes network as shown bellow:

![NetGraph20Nodes](40NodesPlotResults.jpg)

This figure includes the maroon links to highlight a particular tree for data flow (for illustration), while green nodes highlight a particular set of gateways.
The failed links appear in the figure with yellow color, while the cyan links represent the alternative paths (constructed from encoding nodes).

For better understanding of this code,  please see the details of the mathematical model and its constraints in the file "Design of network coding based reliable sensor networks.pdf".
