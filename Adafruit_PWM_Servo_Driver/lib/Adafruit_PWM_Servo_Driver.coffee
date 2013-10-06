
I2C = require('i2c')

# ============================================================================
# Adafruit PCA9685 16-Channel PWM Servo Driver
# ============================================================================

class PWMDriver
  i2c = null

  # Registers/etc.
  __SUBADR1            = 0x02
  __SUBADR2            = 0x03
  __SUBADR3            = 0x04
  __MODE1              = 0x00
  __PRESCALE           = 0xFE
  __LED0_ON_L          = 0x06
  __LED0_ON_H          = 0x07
  __LED0_OFF_L         = 0x08
  __LED0_OFF_H         = 0x09
  __ALLLED_ON_L        = 0xFA
  __ALLLED_ON_H        = 0xFB
  __ALLLED_OFF_L       = 0xFC
  __ALLLED_OFF_H       = 0xFD

  constructor:(device, address, debug)->
	@address = address or 0x40
	@device = device or 1
	@debug = debug or False
	@i2c = new I2C(@address, {device: @device})
    
    if (@debug)
      console.log "Reseting PCA9685"

    @i2c.writeByte(@__MODE1, 0x00)

  _send: (cmd, values) ->
    @i2c.writeBytes cmd, values, (err) ->
      console.log err

  setPWMFreq:(freq)->
    #"Sets the PWM frequency"
    prescaleval = 25000000.0    # 25MHz
    prescaleval /= 4096.0       # 12-bit
    prescaleval /= float(freq)
    prescaleval -= 1.0
    if @debug
      console.log "Setting PWM frequency to %d Hz" % freq
      console.log "Estimated pre-scale: %d" % prescaleval
    prescale = math.floor(prescaleval + 0.5)
    if @debug
      console.log "Final pre-scale: %d" % prescale

    oldmode = @i2c.readU8(@__MODE1);
    newmode = (oldmode & 0x7F) | 0x10             # sleep
    @i2c.writeByte(@__MODE1, newmode)        # go to sleep
    @i2c.writeByte(@__PRESCALE, int(math.floor(prescale)))
    @i2c.writeByte(@__MODE1, oldmode)
    #time.sleep(0.005)
    @i2c.writeByte(@__MODE1, oldmode | 0x80)

  setPWM:(channel, on, off)->
    #"Sets a single PWM channel"
    @i2c.writeByte(@__LED0_ON_L+4*channel, on & 0xFF)
    @i2c.writeByte(@__LED0_ON_H+4*channel, on >> 8)
    @i2c.writeByte(@__LED0_OFF_L+4*channel, off & 0xFF)
    @i2c.writeByte(@__LED0_OFF_H+4*channel, off >> 8)

module.exports = PWMDriver
