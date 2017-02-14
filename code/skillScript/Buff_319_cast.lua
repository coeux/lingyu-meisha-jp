Buff_319_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_319_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_319_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_319_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e319")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdgh" )
	end,

	sdfdgh = function( effectScript )
			AttachBuffEffect( false, Buff_319_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e319",  effectScript)
	end,

}
