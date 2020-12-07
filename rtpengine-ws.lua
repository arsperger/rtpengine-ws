local websocket = require "http.websocket"
local bencode = require "bencode"

RTPENGINE_WS_HOST = "172.16.238.12"
RTPENGINE_WS_PORT = "8080"

local connect_data = {
        url = "ws://"..RTPENGINE_WS_HOST..":"..RTPENGINE_WS_PORT,
        subproto = {
                ng = "ng.rtpengine.com",
                cli = "cli.rtpengine.com",
        }
}

local ws_connect = function(connect_data) 
        WS = assert(websocket.new_from_uri(connect_data.url, { connect_data.subproto.ng }))
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

        local res = { result = "", sdp = ""}
        local cookie = nil;
        local chk_res = nil;

        if not WS then
                if not ws_connect(connect_data) then
                        res.result = "can not connect";
                        return res -- (handle errors in proxy script: sl_reply_error, etc)
                end
        end

        local encoded_data = bencode.encode(data);
        cookie = get_cookie();
        local send_data = cookie.." "..encoded_data;

        local sent = WS:send(send_data)
        if not sent then 
                -- FIXME: broken pipe error
                if not ws_connect(connect_data) then
                        res.result = "can not connect";
                        return res
                else
                        assert(WS:send(send_data)) 
                end
        end       

        local res = WS:receive()
        if not res then
                res.result = "receive error";
                return res
        end

        chk_res = split_string(res)

        if tonumber(chk_res[1]) ~= cookie then
                res.result = "wrong cookie in response?: "..chk_res[1].." and "..cookie;
                return res
        end
        
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

        local res = send_receive(data)
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