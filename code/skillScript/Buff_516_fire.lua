Buff_516_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_516_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_516_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_516_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e516")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adf" )
	end,

	adf = function( effectScript )
			AttachBuffEffect( true, Buff_516_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "e516",  effectScript)
	end,

}
