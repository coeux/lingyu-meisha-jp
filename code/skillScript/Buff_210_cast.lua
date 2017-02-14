Buff_210_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_210_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_210_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_210_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e210")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfd" )
	end,

	dsfd = function( effectScript )
			AttachBuffEffect( false, Buff_210_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e210",  effectScript)
	end,

}
