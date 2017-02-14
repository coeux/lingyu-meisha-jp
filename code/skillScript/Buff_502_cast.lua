Buff_502_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_502_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_502_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_502_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
	end,

	ad = function( effectScript )
			AttachBuffEffect( false, Buff_502_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 2, 100, "e502",  effectScript)
	end,

}
