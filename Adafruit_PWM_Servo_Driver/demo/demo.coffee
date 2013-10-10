PmwServoDriver = require("../main")
sleep = require('sleep')

pwm = new PmwServoDriver(0x40, '/dev/i2c-1', true)

servoMin = 150  # Min pulse length out of 4096
servoMax = 600  # Max pulse length out of 4096

setServoPulse=(channel, pulse)->
  pulseLength = 1000000                   # 1,000,000 us per second
  pulseLength /= 60                       # 60 Hz
  print "%d us per period" % pulseLength
  pulseLength /= 4096                     # 12 bits of resolution
  print "%d us per bit" % pulseLength
  pulse *= 1000
  pulse /= pulseLength
  pwm.setPWM(channel, 0, pulse)

pwm.setPWMFreq(60) # Set frequency to 60 Hz  
pwm.scan()    
              
while true
  # Change speed of continuous servo on channel O
  pwm.setPWM(0, 0, servoMin)
  sleep.sleep(1)
  pwm.setPWM(0, 0, servoMax)
  sleep.sleep(1)
