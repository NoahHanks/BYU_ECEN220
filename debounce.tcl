restart 
run 100 ns 

add_force clk {0 0} {1 5ns} -repeat_every 10ns 
add_force noisy 0
add_force reset 1 
run 1ms 

add_force reset 0
add_force noisy 1 
run 1ms 

add_force noisy 0 
run 1ms 

add_force noisy 1 
run 10ms

add_force noisy 0 
run 10ms 