# AutonomousAgents
Autonomous Agent Navigation via Casual Entropic Forces

Concepts from the paper "Casual Entropic Forces" (Phys. Rev. Lett. 110, 168702 (2013)) are used to perform autonomous navigation in mazes, as well as to play checkers. 

Most code written by Andrew Fishberg and Wai Sing Wong, with some additions by Sean Huver. 

![alt tag](https://github.com/huvers/AutonomousAgents/blob/master/examples/autonomy3%20(3).jpg)

Monte Carlo is performed for k steps after choosing to turn left or right. The turn that leads to the largest number of acceptable outcomes (entropy) in the future is chosen. 


![alt tag](https://github.com/huvers/AutonomousAgents/blob/master/examples/autonomy2%20(1).png)

A simple checkers example. Each actor uses the same algorithm, but neither actor wants to defeat the other because it will lead to the end of the match. "Entropy" needs to be redefined to have a larger positive value for winning a match, rather than 0. 

![alt tag](https://github.com/huvers/AutonomousAgents/blob/master/examples/checkers.png)
