Buff_103_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_103_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_103_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_103_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e103")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
	end,

	ad = function( effectScript )
			AttachBuffEffect( false, Buff_103_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e103",  effectScript)
	end,

}
