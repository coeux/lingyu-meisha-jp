Buff_105_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_105_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_105_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_105_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e105")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safddf" )
	end,

	safddf = function( effectScript )
			AttachBuffEffect( false, Buff_105_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e105",  effectScript)
	end,

}
