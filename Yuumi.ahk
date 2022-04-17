#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Relative
CoordMode, Pixel, Relative


InitialSpellLevelYuumi()
{
	SleepRandom(500)
	send ^e
	SleepRandom(100)
	AttemptShoppingYuumi()
}

YuumiExplore(side, ChampIndex)
{
	return ;this function never gets triggered and does nothing (placeholder)
}

YuumiAttack() ;CORRECTED
{
	PixelSearch, ax, ay, 290, 336, 290, 336, 0x1061B7, 10, Fast RGB
	if ErrorLevel=0
	{
		RandomClickL(80, 45)
		SleepRandom(100)
		send r4q
		return
	}
}

YuumiSurrender()
{
	send {Enter}/ff{Enter}
}

YuumiLogic(side, ChampIndex, gametime) ;CORRECTED
{
	Target:="f"5-ChampIndex
	send {%Target% down} ;centers camera on teammate to follow
	PixelSearch, ax, bx, 315, 350, 315, 350, 0x010d07, 10, Fast RGB ;lowHP check
	if ErrorLevel=0
	{
		send w
		RecallChannel:=YuumiRetreat(side, RecallChannel)
		if RecallChannel>=25
		{
			RecallChannel=0
			if BotRecall()=1 ;recall after 40 clicks ~ 10 seconds of walking to base
			{
				AttemptShoppingYuumi()
			}
		}
		SleepRandom(100)
	}
	Else
	{
		RecallChannel=0
		PixelSearch, ax, ay, 290, 336, 290, 336, 0x1061B7, 20, Fast RGB ;checks if attached in center of w icon
		if ErrorLevel=1
		{
			send ^r^e^w^q
			SleepRandom(100)
			MouseMove, 627-ChampIndex*24, 237 ;target ally icon above map
			SleepRandom(100)
			send w
			SleepRandom(2700)
		}
		else
		{
			Mousemove, 320, 180 ;half the resolution
			SleepRandom(50)
			PixelSearch, xx, xy, 634-ChampIndex*24, 247, 634-ChampIndex*24, 247, 0x131313, 15, Fast RGB ;checks hp bar above map if ally damaged 
			if (ErrorLevel=0 or gametime>=15)
			{
				send e
				SleepRandom(100)
			}
			send ^r^e^w^q
			send {%Target% up}
			SleepRandom(100)
		}
	}
	Return
}

YuumiRetreat(side, RecallChannel) ;CORRECTED
{
	send edf
	if side=1
	{
		IngameHumanClickR(543, 350) ;clicks blue fountain on the map
	}
	if side=2
	{
		IngameHumanClickR(632, 262) ;clicks red fountain on the map
	}
	SleepRandom(100)
	return RecallChannel+1 ;increase recall score...
}

Global YuumiitemsBought=0

AttemptShoppingYuumi()
{

	if not WinExist("League of Legends (TM)")
	{
		return ;ends function early if the game ended
	}
	PixelSearch, ax, by, 0, 0, 640, 360, 0x705729,, Fast RGB ;checking for opened shop window
	if ErrorLevel=0
	{
		send {Escape} ;closing shop if shop window exists
		SleepRandom(500)
	}

	while(YuumiitemsBoughtOld!=YuumiitemsBought)
	{
		if not WinExist("League of Legends (TM)")
		{
			return ;ends function early if the game ended
		}
		YuumiitemsBoughtOld:=YuumiitemsBought
		switch YuumiitemsBought
		{
			case 0:YuumiitemsBought+=YuumibuyItem("spellthief",450)
			case 1:YuumiitemsBought+=YuumibuyItem("oracle",0)
			case 2:YuumiitemsBought+=YuumibuyItem("amplifying tome",435)
			case 3:YuumiitemsBought+=YuumibuyItem("faerie charm",250)
			case 4:YuumiitemsBought+=YuumibuyItem("bandleglass mirror",265)
			case 5:YuumiitemsBought+=YuumibuyItem("ruby crystal",400)
			case 6:YuumiitemsBought+=YuumibuyItem("kindlegem",400)
			case 7:YuumiitemsBought+=YuumibuyItem("moonstone renewer",750)
			case 8:YuumiitemsBought+=YuumibuyItem("amplifying tome",435)
			case 9:YuumiitemsBought+=YuumibuyItem("forbidden idol",800)
			case 10:YuumiitemsBought+=YuumibuyItem("amplifying tome",435)
			case 11:YuumiitemsBought+=YuumibuyItem("ardent censer",630)
			case 12:YuumiitemsBought+=YuumibuyItem("amplifying tome",435)
			case 13:YuumiitemsBought+=YuumibuyItem("forbidden idol",800)
			case 14:YuumiitemsBought+=YuumibuyItem("staff of flowing water",1065)

			default: YuumibuyItem("",0)
		}
	}
	return
}

YuumibuyItem(itemName, itemCost)
{
	if not WinExist("League of Legends (TM)")
		{
		return 0
		}
	
	strStdOut:=StdOutToVar("curl --insecure https://127.0.0.1:2999/liveclientdata/activeplayer")
	goldPos := InStr(strStdOut, "currentGold" , CaseSensitive := true, StartingPos := 1, Occurrence := 1)
	offset=0
	while (char!=".")
	{
		if not WinExist("League of Legends (TM)")
		{
			return 0 ;ends function early if the game ended
		}
		offset:=offset+1
	   	char:=SubStr(strStdOut, goldPos+12+offset, 1)
	}
	goldEndPos:=goldPos+offset-2
	lenght:=(goldEndPos-goldPos)
	currentGold := SubStr(strStdOut, goldPos+14, lenght)

	if (currentGold>itemCost)
		{

		send p
		SleepRandom(500)
		send ^l
		SleepRandom(500)
		send %itemName%
		SleepRandom(500)
		send {enter}
		SleepRandom(500)
		send {escape}
		SleepRandom(500)
		return 1
		}
	
	return 0
}

YuumiResetItemsBought()
{
	YuumiitemsBought=0
}