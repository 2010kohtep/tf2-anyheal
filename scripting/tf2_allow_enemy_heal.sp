#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define nil Address_Null

public Plugin:myinfo = 
{
	name = "[TF2] Allow Enemy Heal",
	author = "2010kohtep",
	description = "Allows to heal enemy players.",
	version = "1.0.0",
	url = "https://github.com/2010kohtep"
};

#pragma newdecls required

Handle hConf;

int ReadByte(Address iAddr)
{
	if(iAddr == nil)
	{
		return -1;
	}
	
	return LoadFromAddress(iAddr, NumberType_Int8);
}

void WriteData(Address iAddr, int[] Data, int iSize)
{
	if(iAddr == nil)
	{
		return;
	}
	
	for (int i = 0; i < iSize; i++)
	{
		StoreToAddress(iAddr + view_as<Address>(i), Data[i], NumberType_Int8);
	}
}

// Return offsetted address
Address GameConfGetAddressEx(Handle h, const char[] patch, const char[] offset)
{
	Address iAddr = GameConfGetAddress(h, patch);
	
	if(iAddr == nil)
	{
		return nil;
	}
	
	int iOffset = GameConfGetOffset(h, offset);
	
	if(iOffset == -1)
	{
		return nil;
	}
	
	iAddr += view_as<Address>(iOffset);
	return iAddr;
}

void Patch_AllowedToHealTarget()
{
	Address iAddr = GameConfGetAddressEx(hConf, "Patch_AllowedToHealTarget", "CWeaponMedigun::AllowedToHealTarget");
	
	if(iAddr == nil)
	{
		LogError("[ERROR] Failed to patch CWeaponMedigun::AllowedToHealTarget()");
		return;
	}
	
	if(ReadByte(iAddr) == 0x75) // Windows
	{
		WriteData(iAddr, {0xEB}, 1);
	}
	else if (ReadByte(iAddr) == 0x89) // Linux
	{
		WriteData(iAddr, {0x90, 0xE9}, 2);
	}
	else
	{
		// TODO: Tell us about unknown signature
	}
}

public void OnPluginStart()
{
	hConf = LoadGameConfigFile("tf2.koh.enemyheal");
	if(hConf == null)
	{
		SetFailState("[ERROR] Can't find tf2.koh.enemyheal gamedata.");
	}

	Patch_AllowedToHealTarget();
	
	delete hConf;
}