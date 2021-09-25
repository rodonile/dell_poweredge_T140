### Important
- This only works with Idrac9 version up to 3.30.30.30 (DELL blocked manual fan control in newer Idrac firmware versions...)

### Use case
- The script sets a static speed to the 2 fans (cpu fan and case fan) depending on temperature
- WHY: The default dynamic PWM algorithm from DELL goes crazy with speed (sounds like a jet engine...), especially with 
  non-officially-supported PCI devices plugged in like my Nvidia GPU 

### Script operation description
- 30% PWM speed at normal temperatures ( CPU temp < 55C and air temp in the case < 33C )
- 35% - 50% PWN gradual PWM increases according to CPU temp increase 
- re-enable DELL's dynamic speed control algorithm for CPU temps > 85C and air temp > 50C (safety feature)

### How to use the script
- set a cronjob to call the script every minute (redirect standard output to log file)
  --> */1 * * * * /dell_ipmi_fan_control.sh >> /fan_logs.log 2>&1