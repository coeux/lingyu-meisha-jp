Buff_303_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_303_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_303_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_303_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e303")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awfsf" )
	end,

	awfsf = function( effectScript )
			AttachBuffEffect( false, Buff_303_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e303",  effectScript)
	end,

}
