M105_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M105_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M105_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M105_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M105_pugong_1")
		PreLoadAvatar("M105_pugong_2")
		PreLoadAvatar("M105_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 15, "fgdg" )
		effectScript:RegisterEvent( 32, "dgfh" )
		effectScript:RegisterEvent( 35, "fdsg" )
		effectScript:RegisterEvent( 38, "dsgfh" )
	end,

	s = function( effectScript )
		SetAnimation(M105_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fgdg = function( effectScript )
		AttachAvatarPosEffect(false, M105_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(160, 65), 0.95, 100, "M105_pugong_1")
	end,

	dgfh = function( effectScript )
		AttachAvatarPosEffect(false, M105_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 20), 1, 100, "M105_pugong_2")
	end,

	fdsg = function( effectScript )
		AttachAvatarPosEffect(false, M105_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "M105_pugong_3")
	end,

	dsgfh = function( effectScript )
			DamageEffect(M105_normal_attack.info_pool[effectScript.ID].Attacker, M105_normal_attack.info_pool[effectScript.ID].Targeter, M105_normal_attack.info_pool[effectScript.ID].AttackType, M105_normal_attack.info_pool[effectScript.ID].AttackDataList, M105_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
