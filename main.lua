-- References:
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/Wire/Wire.h
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/Wire/Wire.cpp
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/LGPS.h
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/LGPS.cpp
-- https://github.com/Seeed-Studio/Arduino_IDE_for_RePhone/blob/master/hardware/arduino/mtk/libraries/LGPS/examples/gps_test/gps_test.ino

json = require "dkjson"

resolveUrl = "https://localhost:3000/"

function lookupHost()
  local host = "127.0.0.1"
  -- make request of resolveUrl
  -- parse JSON response
  -- extract IP address of host
  return host
end

function checkin()
end

gpsDeviceAddress = 0x05

gpsScanId = 0
gpsScanSize = 4

function main()
  local host = lookupHost()
  -- print(host)
  -- print(json.encode({x=5, y="foo"}))

  -- Serial.begin(115200);
  setupI2C(gpsDeviceAddress, 115200)

  --[[
  Data format:
  ID(1 byte), Data length(1 byte), Data 1, Data 2, ... Data n (n bytes, n = data length)
  For example, get the scan data.
  First, Send GPS_SCAN_ID(1 byte) to device.
  Second, Receive scan data(ID + Data length + GPS_SCAN_SIZE = 6 bytes).
  Third, The scan data begin from the third data of received.
  --]]
end

function setupI2C(deviceAddress, baudRate)
  i2c.setup(deviceAddress, baudRate)
end

function gpsCheckOnline()
  local scanValue = i2c.txrx(gpsScanId, 2 + gpsScanSize)
  local scannedDeviceAddress = tonumber(scanValue:sub(6,6))
  return scannedDeviceAddress == gpsDeviceAddress
end

function gpsGetNorthSouth()
end

function gpsGetEastWest()
end

function gpsGetLatitude()
end

function gpsGetLongitude()
end

main()
