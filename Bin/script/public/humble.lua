--[[
C++函数
--]]

local string = string
local pWorkerMgr = g_pWorkerMgr
local pNet = g_pNetWorker
local pSender = g_pSender
local pNetParser = g_pNetParser
local newLuaTask = newLuaTask
local pProtoDisp = g_pProtoDisp
local humble = {}

--网络解析
function humble.setParser(usSockType, strName)
    return pNetParser:setParser(usSockType, strName)
end
function humble.getParserNam(usSockType)
    return pNetParser:getParserNam(usSockType)
end

--监听
function humble.addListener(usSockType, strHost, usPort)
    return pNet:addListener(usSockType, strHost, usPort)
end
function humble.delListener(uiID)   
    pNet:delListener(uiID)
end

--连接处理
function humble.addTcpLink(usSockType, strHost, usPort)
    return pNet:addTcpLink(usSockType, strHost, usPort)
end
function humble.delTcpLink(uiID)   
    pNet:delTcpLink(uiID)
end
function humble.closeSock(sock, uiSession)   
    pNet:closeSock(sock, uiSession)
end
function humble.closeByType(usType)   
    pNet:closeByType(usType)
end

--发送
function humble.Send(sock, uiSession, strBuf)
    pSender:Send(sock, uiSession, strBuf, string.len(strBuf))
end
function humble.sendB(sock, uiSession, pBinary)
    pSender:sendB(sock, uiSession, pBinary)
end
--tsock: {{sock,session},...}
function humble.broadCast(tSock, strBuf)
    if 0 == #tSock then
        return
    end
    
    pSender:broadCast(tSock, strBuf, string.len(strBuf))
end
function humble.broadCastB(tSock, pBinary)
    if 0 == #tSock then
        return
    end
    
    pSender:broadCast(tSock, pBinary)
end
--for udp
function humble.addUdp(strHost, usPort)
    return pNet:addUdp(strHost, usPort)
end
function humble.delUdp(sock)
    pNet:delUdp(sock)
end
function humble.sendU(sock, strHost, usPort, strBuf)
    pSender:sendU(sock, strHost, usPort, strBuf, string.len(strBuf))
end
function humble.sendUB(sock, strHost, usPort, pBinary)
    pSender:sendUB(sock, strHost, usPort, pBinary)
end
function humble.broadCastU(sock, usPort, strBuf)
    pSender:broadCastU(sock, usPort, strBuf, string.len(strBuf))
end
function humble.broadCastUB(sock, usPort, pBinary)
    pSender:broadCastUB(sock, usPort, pBinary)
end

--服务
function humble.getChan(strTaskNam)
    return pWorkerMgr:getChan(strTaskNam)
end
function humble.regTask(strTaskNam)
    return pWorkerMgr:regTask(strTaskNam, newLuaTask())
end

--网络分发
function humble.regProto(proto, strTask)
	assert("string" == type(proto) or "number" == type(proto))
	if "string" == type(proto) then
		pProtoDisp:regStrProto(proto, strTask)
	else
		pProtoDisp:regIProto(proto, strTask)
	end
end

function humble.netToTask(proto, param)
	assert("string" == type(proto) or "number" == type(proto))
	local strTask = nil
	if "string" == type(proto) then
		strTask = pProtoDisp:getStrProto(proto)
	else
		strTask = pProtoDisp:getIProto(proto)
	end
	
	if not strTask then
		return false
	end
	
	local objChan = humble.getChan(strTask)
	if not objChan then
		return false
	end
	
	objChan:Send(param)
	
	return true
end

return humble
