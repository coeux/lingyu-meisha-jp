Buff_404_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_404_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_404_cast.info_pool[effectScript.ID].Attacker)
		Buff_404_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e404")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adff" )
	end,

	adff = function( effectScript )
			AttachBuffEffect( false, Buff_404_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 0.5, 100, "e404",  effectScript)
	end,

}
