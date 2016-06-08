json = require "dkjson"
gps = require "gps"
deque = require "deque"

deviceId = "123"
resolveUrl = "https://localhost:3000/"

functionQueue = deque.new()

function main()
  local host = lookupHost()
  -- print(host)
  -- print(json.encode({x=5, y="foo"}))

  -- Serial.begin(115200);
  setupI2C(gpsDeviceAddress, 115200)

  if gps.isOnline() then
    print("GPS is online")

    local coords = getGpsCoordinates()
    print("current coords: lat=" .. coords[1] .. " long=" .. coords[2])

    -- checkinPeriodically(host, deviceId)
  else
    print("GPS is not online")
  end
end

function setupI2C(deviceAddress, baudRate)
  i2c.setup(deviceAddress, baudRate)
end

-- return array of the form: {lat, long} ; positive latitude is for north latitude and negative latitude is for south latitude; positive longitude is for east longitude and negative longitude is for west longitude
function getGpsCoordinates()
  local latitude = gps.getLatitude()    -- returns a positive value
  if gps.getNorthSouth() == "S" then
    latitude = -latitude
  end

  local longitude = gps.getLongitude()  -- returns a positive value
  if gps.getEastWest() == "W" then
    longitude = -longitude
  end

  return {latitude, longitude}
end

function lookupHost()
  local host = "127.0.0.1"
  -- make request of resolveUrl
  -- parse JSON response
  -- extract IP address of host
  return host
end

function checkinPeriodically(host, deviceId)
  checkin(host, deviceId)

  local fn = function()
    if not functionQueue:is_empty() then
      local f = functionQueue.pop_left()
      f()
    end
  end
  local timerId = timer.create(10000, fn)
  return timerId
end

-- makes a request against the following URL: https://{host}/checkin/{deviceId}/{lat}/{long}
-- with the lat/long of the current GPS coordinates
function checkin(host, deviceId)
  local coords = getGpsCoordinates()
  local lat = coords[1]
  local long = coords[2]

  if type(lat) == "number" and type(long) == "number" then
    response = ""
    local onResponse = function(data, more)
      if more == 0 then
        print('https get response:', response)
        functionQueue.push_right(function() checkin(host, deviceId) end)
      else
        response = response..data
      end
    end

    https.get("https://" .. host .. "/checkin/" .. deviceId .. "/" .. lat .. "/" .. long, onResponse)
  end
end

main()
