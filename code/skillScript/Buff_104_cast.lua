Buff_104_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_104_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_104_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_104_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e104")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "we" )
	end,

	we = function( effectScript )
			AttachBuffEffect( false, Buff_104_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e104",  effectScript)
	end,

}
