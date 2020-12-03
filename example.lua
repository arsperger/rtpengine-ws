local rtpengine = require("rtpengine-ws")

local function split_string (inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end  

local CRLF = "\r\n";

local sdp = "v=0"..CRLF..
"o=- 8572293204531150118 2 IN IP4 127.0.0.1"..CRLF..
"s=-"..CRLF..
"t=0 0"..CRLF..
"a=group:BUNDLE audio video"..CRLF..
"m=audio 9 UDP/TLS/RTP/SAVPF  0 8"..CRLF..
"c=IN IP4 0.0.0.0"..CRLF..
"a=rtcp:9 IN IP4 0.0.0.0"..CRLF..
"a=sendrecv"..CRLF..
"a=rtcp-mux"..CRLF..
"a=rtpmap:0 PCMU/8000"..CRLF..
"a=rtpmap:8 PCMA/8000"

local call_id = "cfBXzDSZqhYNcXM"; 
local from_tag = "mS9rSAn0Cr";

local to_tag = "cds84jnjddw"

local params = {  
    ["flags"] = {"trust address"},
    ["replace"] = { "origin", "session connection"},
    ["ICE"] = "remove", 
    ["transport protocol"] = "RTP/AVPF", 
    ["media address"] = "172.23.23.23", 
    ["DTLS"] ="passive"
};

--[[ sdp.sdp containes SDP 
local sdp = rtpengine.offer(call_id, from_tag, to_tag, sdp, params)

local parsed_sdp = split_string(sdp.sdp, CRLF)

for k,v in ipairs(parsed_sdp) do
    print(k,v)
end
]]

--[[ answer test ]]
local sdp = rtpengine.answer(call_id, from_tag, to_tag, sdp, params)

print (sdp.sdp)
--]]

--[[ delete test 
local del = rtpengine.delete(call_id, from_tag)

for k,v in pairs(del) do
    print(k,v)
end

--print(del)
]]