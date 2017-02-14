Buff_201_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_201_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_201_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_201_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adf" )
	end,

	adf = function( effectScript )
			AttachBuffEffect( false, Buff_201_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e201",  effectScript)
	end,

}
