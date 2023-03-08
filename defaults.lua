-- Defaults


-- Import the dkjson library
local dkjson = require("dkjson")

-- Define the class
local Defaults = {}

-- Constructor function
function Defaults:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self

  -- Check if the defaults file exists
  local file = io.open("defaults.json", "r")
  if file == nil then
    -- If the file doesn't exist, fill it with default data
    self:write_default_data()
  else
    file:close()
  end

  return obj
end

-- Function to write data to the JSON file
function Defaults:write_data(data)
  -- Encode the data table to a JSON string
  local json_str = dkjson.encode(data)

  -- Open the defaults file for writing
  local file = io.open("defaults.json", "w")

  -- Write the JSON string to the file
  file:write(json_str)

  -- Close the file
  file:close()
end

-- Function to read data from the JSON file
function Defaults:read_data()
  -- Open the defaults file for reading
  local file = io.open("defaults.json", "r")

  -- Read the contents of the file
  local json_str = file:read("*all")

  -- Decode the JSON string to a Lua table
  local data = dkjson.decode(json_str)

  -- Close the file
  file:close()

  -- Return the data table
  return data
end

-- Function to write default data to the JSON file
function Defaults:write_default_data()
  local default_data = self:get_default_data()
  self:write_data(default_data)
end

-- Function to define the default data table
function Defaults:get_default_data()
  return {
    name = "John Smith",
    age = 42,
    hobbies = {"reading", "running", "coding"},
    address = {
      street = "123 Main St",
      city = "Anytown",
      state = "CA",
      zip = "12345"
    }
  }
end

-- Return the class
return Defaults

