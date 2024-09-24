local QBCore = exports['qb-core']:GetCoreObject()
local colors = {
	[0] = 'black',
	[1] = 'black',
	[2] = 'black',
	[55] = 'black',
	[56] = 'black',
	[57] = 'black',
	[58] = 'black',
	[59] = 'black',
	[60] = 'black',
	[61] = 'black',
	[3] = 'brown',
	[4] = 'brown',
	[5] = 'brown',
	[6] = 'brown',
	[7] = 'brown',
	[8] = 'brown',
	[9] = 'blonde',
	[10] = 'blonde',
	[11] = 'blonde',
	[12] = 'blonde',
	[13] = 'blonde',
	[14] = 'blonde',
	[15] = 'blonde',
	[16] = 'blonde',
	[62] = 'blonde',
	[63] = 'blonde',
	[26] = 'gray',
	[27] = 'gray',
	[28] = 'gray',
	[29] = 'gray',
	[30] = 'purple',
	[31] = 'purple',
	[32] = 'purple',
	[33] = 'pink',
	[34] = 'pink',
	[35] = 'pink',
	[36] = 'turquoise',
	[37] = 'turquoise',
	[38] = 'turquoise',
	[39] = 'green',
	[40] = 'green',
	[41] = 'green',
	[42] = 'green',
	[43] = 'green',
	[44] = 'green',
	[45] = 'yellow',
	[46] = 'yellow',
	[47] = 'orange',
	[48] = 'orange',
	[49] = 'orange',
	[51] = 'orange',
	[52] = 'orange'
}

local letter = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'X', 'Y'}

math.randomseed(os.time())

-- Fetch
QBCore.Functions.CreateCallback('jomidar-criminalrecord:fetch', function(source, cb, data, type)
    if type == 'start' then
        exports.oxmysql:execute('SELECT date, offense, institution, charge, term, classified FROM jomidar_criminalrecord', {}, function(result)
            cb(result)
        end)
    elseif type == 'record' then
      exports.oxmysql:execute('SELECT * FROM jomidar_criminalrecord WHERE offense = ?', {data.offense}, function(resultRecord)
        if resultRecord and resultRecord[1] then
            -- Ensure that resultRecord[1] contains an identifier
            if resultRecord[1].identifier then
                exports.oxmysql:execute('SELECT firstname, lastname, sex FROM jomidar_criminaluserinfo WHERE identifier = ?', {resultRecord[1].identifier}, function(resultUser)
                    if resultUser and resultUser[1] then
                        local array = {
                            userinfo = resultUser,
                            records = resultRecord
                        }
                        cb(array)
                    else
                        print("User not found for identifier: " .. resultRecord[1].identifier)
                        cb('error')  -- Return error if user data is not found
                    end
                end)
            else
                print("No identifier found for offense: " .. data.offense)  -- Debugging: Log missing identifier
                cb('error')
            end
        else
            print("No records found for offense: " .. data.offense)  -- Debugging: Log if no offense record is found
            cb('error')
        end
    end)
    
    elseif type == 'user' then
        exports.oxmysql:execute('SELECT * FROM jomidar_criminaluserinfo WHERE dob = ?', {data.dob}, function(resultUser)
            exports.oxmysql:execute('SELECT * FROM jomidar_criminalrecord WHERE identifier = ?', {resultUser[1].identifier}, function(resultRecord)
                local array = {
                    userinfo = resultUser,
                    records = resultRecord
                }
                cb(array)
            end)
        end)
    end
end)

-- Search
QBCore.Functions.CreateCallback('jomidar-criminalrecord:search', function(source, cb, data)
    local query = 'SELECT * FROM jomidar_criminaluserinfo'
    local queryVal = nil

    if string.len(data.dob) > 0 then
        query = 'SELECT * FROM jomidar_criminaluserinfo WHERE dob = ?'
        queryVal = data.dob
    elseif string.len(data.firstname) > 0 then
        query = 'SELECT * FROM jomidar_criminaluserinfo WHERE firstname = ?'
        queryVal = data.firstname
    elseif string.len(data.lastname) > 0 then
        query = 'SELECT * FROM jomidar_criminaluserinfo WHERE lastname = ?'
        queryVal = data.lastname
    elseif string.len(data.offense) > 0 then
        cb('ok')
    end

    if queryVal == nil then
        exports.oxmysql:execute(query, {}, function(result)
            if result[1] ~= nil then
                cb(result)
            else
                cb('error')
            end
        end)
    else
        exports.oxmysql:execute(query, {queryVal}, function(result)
            if result[1] ~= nil then
                cb(result)
            else
                cb('error')
            end
        end)
    end
end)

-- Add
QBCore.Functions.CreateCallback('jomidar-criminalrecord:add', function( source, cb, data )
  local recordid = letter[math.random(1,6)] .. math.random(0,999) .. letter[math.random(1,6)] .. math.random(0,999)
  local weight   = 0
  local Player = QBCore.Functions.GetPlayer(source)
  local warden = Player.PlayerData.charinfo.firstname
  local date    = data.date
  local offense = letter[math.random(1,6)] .. '-' .. math.random(100,999)

  if date == 'Today' then
    date = os.date('%Y-%m-%d')
  end

      MySQL.Async.fetchAll('SELECT identifier FROM jomidar_criminaluserinfo WHERE identifier = @identifier', {['@identifier'] = identifier},
      function (resultCheck)
        if resultCheck[1] == nil then
          MySQL.Async.execute('INSERT INTO jomidar_criminaluserinfo (identifier, aliases, recordid, weight, eyecolor, haircolor, firstname, lastname, dob, sex, height) VALUES (@identifier, @aliases, @recordid, @weight, @eyecolor, @haircolor, @firstname, @lastname, @dob, @sex, @height)',
           {
             ['@identifier'] = recordid,
             ['@aliases']    = data.firstname,
             ['@recordid']   = recordid,
             ['@weight']     = 100 .. 'kg',
             ['@eyecolor']   = 'black',
             ['@haircolor']  = 'black',
             ['@firstname']  = data.firstname,
             ['@lastname']   = data.lastname,
             ['@dob']        = data.dob,
             ['@sex']        = 'M',
             ['@height']     = 110 .. 'cm'
           },
           function (rowsChanged)
             MySQL.Async.execute('INSERT INTO jomidar_criminalrecord (offense, date, institution, charge, description, term, classified, identifier, dob, warden) VALUES (@offense, @date, @institution, @charge, @description, @term, @classified, @identifier, @dob, @warden)',
              {
                ['@offense']     = offense,
                ['@date']        = date,
                ['@institution'] = 'Bolingbroke',
                ['@charge']      = data.charge,
                ['@description'] = data.description,
                ['@term']        = data.term,
                ['@classified']  = 0,
                ['@identifier']  = recordid,
                ['@dob']         = data.dob,
                ['@warden']      = warden
              },
              function (rowsChanged)
                MySQL.Async.fetchAll('SELECT * FROM jomidar_criminalrecord WHERE offense = @offense', {['@offense'] = offense},
                 function (result)
                   if result[1] ~= nil then
                     MySQL.Async.fetchAll('SELECT * FROM jomidar_criminaluserinfo WHERE UPPER(firstname) = @firstname AND UPPER(lastname) = @lastname AND dob = @dob', {['@firstname'] = data.firstname, ['@lastname'] = data.lastname, ['@dob'] = data.dob},
                      function (uinfo)
                        if uinfo[1] ~= nil then
                          local array = {
                            userinfo = uinfo,
                            records = result
                          }

                          cb(array)
                        end
                      end)
                   end
                 end)
             end)
          end)
        else
          MySQL.Async.execute('INSERT INTO jomidar_criminalrecord (offense, date, institution, charge, description, term, classified, identifier, dob, warden) VALUES (@offense, @date, @institution, @charge, @description, @term, @classified, @identifier, @dob, @warden)',
           {
             ['@offense']     = offense,
             ['@date']        = date,
             ['@institution'] = 'LSPD',
             ['@charge']      = data.charge,
             ['@description'] = data.description,
             ['@term']        = data.term,
             ['@classified']  = 0,
             ['@identifier']  = identifier,
             ['@dob']         = data.dob,
             ['@warden']      = warden
           },
           function (rowsChanged)
             MySQL.Async.fetchAll('SELECT * FROM jomidar_criminalrecord WHERE offense = @offense', {['@offense'] = offense},
              function (result)
                if result[1] ~= nil then
                  MySQL.Async.fetchAll('SELECT * FROM jomidar_criminaluserinfo WHERE UPPER(firstname) = @firstname AND UPPER(lastname) = @lastname AND dob = @dob', {['@firstname'] = data.firstname, ['@lastname'] = data.lastname, ['@dob'] = data.dob},
                   function (uinfo)
                     if uinfo[1] ~= nil then
                       local array = {
                         userinfo = uinfo,
                         records = result
                       }
                       cb(array)
                     end
                   end)
                end
              end)
          end)
        end
   end)
end)


-- Update
QBCore.Functions.CreateCallback('jomidar-criminalrecord:update', function(source, cb, data)
    if data.description ~= nil then
        exports.oxmysql:execute('UPDATE jomidar_criminalrecord SET description = ? WHERE offense = ?', {data.description, data.offense})
        cb('ok')
    elseif data.classified ~= nil then
        exports.oxmysql:execute('UPDATE jomidar_criminalrecord SET classified = ? WHERE offense = ?', {data.classified, data.offense})
        cb('ok')
    end
end)

-- Remove
QBCore.Functions.CreateCallback('jomidar-criminalrecord:remove', function(source, cb, data)
    exports.oxmysql:execute('SELECT identifier FROM jomidar_criminalrecord WHERE offense = ?', {data.offense}, function(resultID)
        exports.oxmysql:execute('SELECT * FROM jomidar_criminalrecord WHERE identifier = ?', {resultID[1].identifier}, function(resultAll)
            if #resultAll < 2 then
                exports.oxmysql:execute('DELETE FROM jomidar_criminaluserinfo WHERE identifier = ?', {resultID[1].identifier})
            end
            exports.oxmysql:execute('DELETE FROM jomidar_criminalrecord WHERE offense = ?', {data.offense})
            cb('ok')
        end)
    end)
end)
