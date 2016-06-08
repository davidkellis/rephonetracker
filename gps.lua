-- References:
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/Wire/Wire.h
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/Wire/Wire.cpp
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/LGPS.h
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/LGPS.cpp
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/examples/gps_test/gps_test.ino

local gps = {}

--[[
	GPS_DEVICE_ADDR
	The I2C address GPS

	GPS_SCAN_ID
	The id of scan data, the format is 0,0,0,Device address
	GPS_SCAN_SIZE
	The length of scan data

	GPS_UTC_DATE_TIME_ID
	The id of utc date and time, the format is YMDHMS
	GPS_UTC_DATE_TIME_SIZE
	The length of utc date and time data

	GPS_STATUS_ID
	The id of GPS status, the format is A/V
	GPS_STATUS_SIZE
	The length of GPS status data

	GPS_LATITUDE_ID
	The id of latitude, the format is dd.dddddd
	GPS_LATITUDE_SIZE
	The length of latitude data

	GPS_NS_ID
	The id of latitude direction, the format is N/S
	GPS_NS_SIZE
	The length of latitude direction data

	GPS_LONGITUDE_ID
	The id of longitude, the format is ddd.dddddd
	GPS_LONGITUDE_SIZE
	The length of longitude data

	GPS_EW_ID
	The id of longitude direction, the format is E/W
	GPS_EW_SIZE
	The length of longitude direction data

	GPS_SPEED_ID
	The id of speed, the format is 000.0~999.9 Knots
	GPS_SPEED_SIZE
	The length of speed data

	GPS_COURSE_ID
	The id of course, the format is 000.0~359.9
	GPS_COURSE_SIZE
	The length of course data

	GPS_POSITION_FIX_ID
	The id of position fix status, the format is 0,1,2,6
	GPS_POSITION_FIX_SIZE
	The length of position fix status data

	GPS_SATE_USED_ID
	The id of state used, the format is 00~12
	GPS_SATE_USED_SIZE
	The length of sate used data

	GPS_ALTITUDE_ID
	The id of altitude, the format is -9999.9~99999.9
	GPS_ALTITUDE_SIZE
	The length of altitude data

	GPS_MODE_ID
	The id of locate mode, the format is A/M
	GPS_MODE_SIZE
	The length of locate mode data

	GPS_MODE2_ID
	The id of current status, the format is 1,2,3
	GPS_MODE2_SIZE
	The length of current status data

  Data format:
  ID(1 byte), Data length(1 byte), Data 1, Data 2, ... Data n (n bytes, n = data length)
  For example, get the scan data.
  First, Send GPS_SCAN_ID(1 byte) to device.
  Second, Receive scan data(ID + Data length + GPS_SCAN_SIZE = 6 bytes).
  Third, The scan data begin from the third data of received.
--]]

gpsDeviceAddress = 0x05

gpsScanId = 0
gpsScanSize = 4         -- 4 bytes - [0,0,0,Device address (0x05)]

gpsUtcDateTimeId = 1
gpsUtcDateTimeSize = 6  -- 6 bytes - [Y,M,D,H,M,S]

gpsStatusId	= 2
gpsStatusSize	= 1       -- 1 byte - A/V - Return A or V. A is orientation, V is navigation.

gpsLatitudeId = 3
gpsLatitudeSize = 9     -- 9 bytes - dd.dddddd

gpsNsId = 4
gpsNsSize = 1           -- 1 byte - N/S - Return latitude direction data. The format is N/S. N is north, S is south.

gpsLongitudeId = 5
gpsLongitudeSize = 10   -- 10 bytes - ddd.dddddd

gpsEwId = 6
gpsEwSize = 1           -- 1 byte - E/W - Return longitude direction data. The format is E/W. E is east, W is west.

gpsSpeedId = 7
gpsSpeedSize = 5        -- 5 bytes - 000.0~999.9 Knots

gpsCourseId = 8
gpsCourseSize = 5       -- 5 bytes - 000.0~359.9

gpsPositionFixId = 9
gpsPositionFixSize = 1  -- 1 byte - 0,1,2,6

gpsSateUsedId = 10
gpsSateUsedSize = 2     -- 2 bytes - 00~12

gpsAltitudeId = 11
gpsAltitudeSize = 7     -- 7 bytes - -9999.9~99999.9

gpsModeId = 12
gpsModeSize = 1         -- 1 byte - A/M - Return mode of location. The format is A/M. A:automatic, M:manual.

gpsMode2Id = 13
gpsMode2Size = 1        -- 1 byte - 1,2,3 - Return current status. The format is 1,2,3. 1:null, 2:2D, 3:3D.


-- NOTE: All of the GPS interaction functions defined below require that i2c has been properly set up with a call to: i2c.setup(deviceAddress, baudRate)
-- For example: setupI2C(gpsDeviceAddress, 115200)

-- get the status of the device
-- returns true if online, false if offline
function gps.isOnline()
  local data = i2c.txrx(gpsScanId, 2 + gpsScanSize)    -- 6 bytes total; first two are [id byte, data length byte], followed by payload; first two are [id byte, data length byte], followed by payload; payload is 4 bytes - [0,0,0,Device address (0x05)]
  local scannedDeviceAddress = tonumber(data:sub(6,6))
  return scannedDeviceAddress == gpsDeviceAddress
end

-- get the UTC date and time
-- returns a string in the format YMDHMS
function gps.getUtcDateTime()
  local data = i2c.txrx(gpsUtcDateTimeId, 2 + gpsUtcDateTimeSize)   -- 8 bytes total; first two are [id byte, data length byte], followed by payload; payload is 6 bytes - [Y,M,D,H,M,S]
  local timestamp = data:sub(3,8)
  return timestamp
end

-- get the status of the GPS
-- return A or V. A is orientation, V is navigation.
function gps.getStatus()
  local data = i2c.txrx(gpsStatusId, 2 + gpsStatusSize)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - A/V - Return A or V. A is orientation, V is navigation.
  local status = data:sub(3,3)
end

-- get the latitude direction
-- return latitude direction data. The format is N/S. N is north, S is south. if the GPS responds with anything other than N or S, this function returns nil.
function gps.getNorthSouth()
  local data = i2c.txrx(gpsNsId, 2 + gpsNsSize)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - N/S - Return latitude direction data. The format is N/S. N is north, S is south.
  local ns = data:sub(3,3)
  return (ns == "N" or ns == "S") and ns or nil   -- "(boolean expression) and X or Y" is as close as Lua gets to a ternary operator => (boolean expression) ? X : Y
end

-- get the latitude
-- return latitude data. The format is dd.dddddd
function gps.getLatitude()
  local data = i2c.txrx(gpsLatitudeId, 2 + gpsLatitudeSize)   -- 11 bytes total; first two are [id byte, data length byte], followed by payload; payload is 9 bytes - dd.dddddd
  local latitude = tonumber(data:sub(3,11))   -- convert the string representation of the decimal latitude to a numeric representation
  return latitude
end

-- get the longitude direction.
-- return longitude direction data. The format is E/W. E is east, W is west. if the GPS responds with anything other than E or W, this function returns nil.
function gps.getEastWest()
  local data = i2c.txrx(gpsEwId, 2 + gpsEwSize)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - E/W - Return longitude direction data. The format is E/W. E is east, W is west.
  local ew = data:sub(3,3)
  return (ew == "E" or ew == "W") and ew or nil   -- "(boolean expression) and X or Y" is as close as Lua gets to a ternary operator => (boolean expression) ? X : Y
end

-- get the longitude.
-- return longitude data. The format is ddd.dddddd.
function gps.getLongitude()
  local data = i2c.txrx(gpsLongitudeId, 2 + gpsLongitudeSize)   -- 12 bytes total; first two are [id byte, data length byte], followed by payload; payload is 10 bytes - ddd.dddddd
  local longitude = tonumber(data:sub(3,12))   -- convert the string representation of the decimal longitude to a numeric representation
  return longitude
end

-- get the speed.
-- return speed data. The format is 000.0~999.9 Knots.
function gps.getSpeed()
  local data = i2c.txrx(gpsSpeedId, 2 + gpsSpeedSize)   -- 7 bytes total; first two are [id byte, data length byte], followed by payload; payload is 5 bytes - 000.0~999.9 Knots
  local speed = tonumber(data:sub(3,7))   -- convert the string representation of the decimal speed to a numeric representation
  return speed
end

-- get the course.
-- return course data. The format is 000.0~359.9.
function gps.getCourse()
  local data = i2c.txrx(gpsCourseId, 2 + gpsCourseSize)   -- 7 bytes total; first two are [id byte, data length byte], followed by payload; payload is 5 bytes - 000.0~359.9
  local course = tonumber(data:sub(3,7))   -- convert the string representation of the decimal course to a numeric representation
  return course
end

-- Get the status of position fix.
-- Return course data. The format is 0,1,2,6.
function gps.getPositionFix()
  local data = i2c.txrx(gpsPositionFixId, 2 + gpsPositionFixSize)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - 0,1,2,6
  local positionFix = tonumber(data:sub(3,3))   -- convert string representation of the positionFix to an integer
  return positionFix
end

-- Get the number of state used.
-- Return number of state used. The format is 0-12.
function gps.getSateUsed()
  local data = i2c.txrx(gpsSateUsedId, 2 + gpsSateUsedSize)   -- 4 bytes total; first two are [id byte, data length byte], followed by payload; payload is 2 bytes - 00~12
  local count = tonumber(data:sub(3,4))   -- convert string representation of the count to an integer
  return count
end

-- Get the altitude. the format is -9999.9~99999.9
-- Return altitude data. The format is -9999.9~99999.9
function gps.getAltitude()
  local data = i2c.txrx(gpsAltitudeId, 2 + gpsAltitudeSize)   -- 9 bytes total; first two are [id byte, data length byte], followed by payload; payload is 7 bytes - -9999.9~99999.9
  local altitude = tonumber(data:sub(3,9))   -- convert the string representation of the decimal altitude to a numeric representation
  return altitude
end

-- Get the mode of location.
-- Return mode of location. The format is A/M. A:automatic, M:manual. if the GPS responds with anything other than A or M, this function returns nil.
function gps.getMode()
  local data = i2c.txrx(gpsModeId, 2 + gpsModeSize)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - A/M - Return mode of location. The format is A/M. A:automatic, M:manual.
  local am = data:sub(3,3)
  return (am == "A" or am == "M") and am or nil   -- "(boolean expression) and X or Y" is as close as Lua gets to a ternary operator => (boolean expression) ? X : Y
end

-- Get the current status of GPS.
-- Return the current integer status - 1, 2, or 3. The format is 1,2,3. 1:null, 2:2D, 3:3D. if the GPS responds with anything other than "1", "2", or "3", this function returns nil.
function gps.getMode2()
  local data = i2c.txrx(gpsMode2Id, 2 + gpsMode2Size)   -- 3 bytes total; first two are [id byte, data length byte], followed by payload; payload is 1 byte - 1,2,3 - Return current status. The format is 1,2,3. 1:null, 2:2D, 3:3D.
  local mode = data:sub(3,3)
  return (mode == "1" or mode == "2" or mode == "3") and tonumber(mode) or nil   -- "(boolean expression) and X or Y" is as close as Lua gets to a ternary operator => (boolean expression) ? X : Y
end

return gps
