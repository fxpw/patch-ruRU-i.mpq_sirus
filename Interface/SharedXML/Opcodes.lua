--	Filename:	Opcodes.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local Opcodes = {}
function RegisterOpcode(name, opcode)
	_G[name] = opcode
	Opcodes[opcode] = name
end

function GetOpcodeName(opcode)
	return Opcodes[opcode]
end

function IsOpcode(name)
	return Opcodes[_G[name]] ~= nil
end

RegisterOpcode("CMSG_SIRUS_OPEN_URL", 0x520);
RegisterOpcode("SMSG_SIRUS_OPEN_URL", 0x521);
RegisterOpcode("CMSG_SIRUS_BOOST_STATUS", 0x522);
RegisterOpcode("SMSG_SIRUS_BOOST_STATUS", 0x523);
RegisterOpcode("CMSG_SIRUS_BOOST_BUY", 0x524);
RegisterOpcode("SMSG_SIRUS_BOOST_BUY", 0x525);
RegisterOpcode("CMSG_SIRUS_BOOST_CHARACTER", 0x526);
RegisterOpcode("SMSG_SIRUS_BOOST_CHARACTER", 0x527);
RegisterOpcode("CMSG_SIRUS_DELETED_CHARACTER_INFO", 0x528);
RegisterOpcode("SMSG_SIRUS_DELETED_CHARACTER_INFO", 0x529);
RegisterOpcode("CMSG_SIRUS_DELETED_CHARACTER_LIST", 0x52A);
RegisterOpcode("SMSG_SIRUS_DELETED_CHARACTER_LIST", 0x52B);
RegisterOpcode("CMSG_SIRUS_DELETED_CHARACTER_RESTORE", 0x52C);
RegisterOpcode("SMSG_SIRUS_DELETED_CHARACTER_RESTORE", 0x52D);
