# COP 5615 - Project 2
Program to implement Gossip and Push-sum algorithms

## Group Info
  - Anand Chinnappan Mani,  UFID: 7399-9125
  - Utkarsh Roy,            UFID: 9109-6657

## Instructions
Move to project working directory
```
  iex -S mix
  Sample.start <numNodes>, <line|full|3D|rand2D|torus|impLine>, <gossip|push-sum>
```

Sample Input 1:
```
  iex -S mix
  Sample.start 250, "line", "gossip"
```
Sample Output 1:
```
:ok
Total nodes converged = 1/250
Total nodes converged = 2/250
.
.
.
Total nodes converged = 176/250
Finished. Time taken: 11.811416
** (EXIT from #PID<0.128.0>) shell process exited with reason: "Voluntary Termination"
```


Sample Input 2:
```
Sample.start 200, "torus", "push-sum"
```
Sample Output 2:
```
:ok
Total nodes converged = 1/200
.
.

Total nodes converged = 199/200
Total nodes converged = 200/200
Finished. Time taken: 0.728586
** (EXIT from #PID<0.145.0>) shell process exited with reason: "Voluntary Termination"
```
##Working

###Gossip Algorithm
- Upon hearing a rumour the node becomes active and gossips every 50 milliseconds. 
- All active nodes gossip in each cycle.
- Node stops transmitting on hearing the rumour 10 times 
- Program termination condtion: 70% of the nodes receive the rumour

###Push-sum algorithm
- Only one node transmitting in each cycle
- Node records convergence when delta(s/w) < 10^-10 for 3 consecutive rounds
- Node continues transmitting after convergence to ensure convergence of neighbouring nodes
- Program termination condition: All nodes reach convergence

###What is working 
- Convergence of both algorithms for all 6 topologies 
- BONUS: Convergence of Gossip algorithm under varying failure rates


## Conclusions
#### Processor used
Intel® Core™ i5-3427U Processor
https://ark.intel.com/products/64903/Intel-Core-i5-3427U-Processor-3M-Cache-up-to-2_80-GHz)

#### Work unit for best performance
![N|Solid](https://i.imgur.com/Kg7F7fL.png)
 Figure - 1: Decrease in execution time shows concurrency 
 
![N|Solid](https://i.imgur.com/BZfHTaG.png)
Figure - 2: Maximum CPU-Real time ratio is uniform (~3.5) for varying problem sizes which is less than number of threads (4)

On running our program for various values of N, we observed that the execution time had nearly halved for two actors. There was no significant change in the execution time for actors upto 5.  (As seen in Figure - 1)
Further, by plotting the ratio of CPU time to Real time against the Number of actors, we could conclude that the best results were for ~ 4 actors (As seen in Figure - 2)
Going by the above two observations, we conclude that using **4 actors gives us the best performance, thereby resulting in the best work unit to be equal to N/4**

>The best CPU-real time ratio of ~ 3.5 aligns with the fact that this was run on a Intel® Core™ i5-3427U Processor, which has 4 threads (2cores + hyperthreading) 

**In general, the best work unit size would be N/number of cores**

#### Result of running for n = 1000000, k = 4
```
elixir proj1.exs 1000000 4 
```
This resulted in zero solutions

#### Running time for n = 1000000, k = 4
![N|Solid](https://i.imgur.com/Ja3cfiU.png?1)
Table - 1: Results for varying number of actors. Linux 'time' command was used for measurement. Best Real time 0.755s, CPU-Real time ratio 2.18

![N|Solid](https://i.imgur.com/BxmM13F.png)
Figure - 3: Number of cores for increasing number of processes

Observations:
 - Best **Real time 0.755s**, **CPU-Real time ratio 2.18** was acheived on using 4 actors (depicted in Table -1, Figure - 3), thus reinforcing the conclusion made earlier. 
 - The CPU-Real time ratio 2.18 shows that **effectively 3 cores were used in computation**. As the problem size is small, not all the threads are utilized. 
 - Furthermore, addition of more actors only adds an overhead to compute a problem of this size, due to which the CPU-Real time ratio decreases beyond 4 actors.

#### Largest problem solved
 - N = 1,000,000,000 and k =24. We ended up with 2427 solutions and can be found in "solution_1b.txt"
 - Attempting to solve for N = 100,000,000,000 and k = 24 ended up with a couple of actors being killed, thereby resulting in an incomplete solution. The incomplete solution can be found in "solution_100b_incomplete.txt".
 - Attempts to solve for N = 10,000,000,000 and k = 24; N = 5,000,000,000 and k = 24 on another machine resulted in 'Cannot Allocate xyz bytes of memory' error. 



### Todos
 - Implement supervisor for fault-tolerance
 - Attempt to solve the same on remote nodes
 - Why is the system time changing while running the application with varying actors? Aren't the number of kernel operations constant, thereby resulting in a similar system time?
 - How can the CPU-Real time ratio be greater than 1 when number of actors = 1?
