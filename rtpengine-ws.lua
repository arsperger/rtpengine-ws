local websocket = require "http.websocket"
local bencode = require "bencode"

local result = {result = "", sdp = ""}

local connect_data = {
        url = "ws://172.16.238.12:8080",
        subproto = {
                ng = "ng.rtpengine.com",
                cli = "cli.rtpengine.com",
        }
}

local ws_connect = function(connect_data) 
        WS = websocket.new_from_uri(connect_data.url, { connect_data.subproto.ng })
        local con = WS:connect()
        if not con then return false else return true end
end

local function split_string (inputstr, sep)
        if sep == nil then sep = "%s" end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end    

local function get_cookie ()
        math.randomseed(os.time());
        return (math.random(1000,9000)); 
end

local function send_receive(data)

        if not WS then
                if ws_connect(connect_data) == false then
                        result.result = "can not connect";
                        return result
                end
        end

        local encoded_data = bencode.encode(data);
        local cookie = get_cookie();
        local send_data = cookie.." "..encoded_data;

        local sent = WS:send(send_data)
        if not sent then 
                result.result = "can not send data";
                return result
        end       

        local res = WS:receive()
        if not res then
                result.result = "can not receive data";
                return result
        end

        local chk_res = split_string(res)

        if tonumber(chk_res[1]) ~= cookie then
                result.result = "wrong cookie in response ?";
                return result
        end

        assert(WS:close())

        return res
end

local function rtpengine_manage(command, call_id, from_tag, to_tag, sdp, params)

        local data = {};
        data = params;

        data["command"] = command;
        data["call-id"] = call_id;
        data["from-tag"] = from_tag;
        if to_tag ~= nil then 
                data["to-tag"] = to_tag;
        end
        data["sdp"] = sdp;
    
        local encoded_data = bencode.encode(data);
        local cookie = get_cookie();
        local send_data = cookie.." "..encoded_data;

        local res = send_receive(data)
        -- yes, we decode twice because rtpengine returns cookie
        local result = bencode.decode(bencode.decode(res));

        --result = { result = "ok", sdp = "o=1 \r\n.."}
        return result
end

local function rtpengine_delete(call_id, from_tag, to_tag, via_branch)

        local data = {};
        data["command"] = "delete";
        data["call-id"] = call_id;
        data["from-tag"] = from_tag;
        if to_tag ~= nil then 
                data["to-tag"] = to_tag;
        end
        if via_branch ~= nil then
                data["via-branch"] = via_branch;
        end
    
       local res = send_receive(data)
       local result = bencode.decode(bencode.decode(res));

       return result
end

function offer(call_id, from_tag, to_tag, sdp, params)
        return rtpengine_manage("offer", call_id, from_tag, to_tag, sdp, params)
end

function answer(call_id, from_tag, to_tag, sdp, params)
        return rtpengine_manage("answer", call_id, from_tag, to_tag, sdp, params)
end

function delete(call_id, from_tag, to_tag, via_branch)
        return rtpengine_delete(call_id, from_tag, to_tag, via_branch)
end

return { 
        offer = offer, 
        answer = answer,
        delete = delete
}