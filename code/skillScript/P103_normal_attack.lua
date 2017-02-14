P103_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_normal_attack.info_pool[effectScript.ID].Attacker)
        
		P103_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010131")
		PreLoadAvatar("P103_pugong_2")
		PreLoadAvatar("P103_pugong_1")
		PreLoadAvatar("P103_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfds" )
		effectScript:RegisterEvent( 6, "szfcdf" )
		effectScript:RegisterEvent( 7, "ghjhj" )
		effectScript:RegisterEvent( 24, "saffg" )
		effectScript:RegisterEvent( 26, "sfdg" )
	end,

	sfds = function( effectScript )
		SetAnimation(P103_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s010131")
	end,

	szfcdf = function( effectScript )
		AttachAvatarPosEffect(false, P103_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 90), 1.2, 100, "P103_pugong_2")
	end,

	ghjhj = function( effectScript )
		AttachAvatarPosEffect(false, P103_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-100, 145), 2, 100, "P103_pugong_1")
	end,

	saffg = function( effectScript )
		AttachAvatarPosEffect(false, P103_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "P103_pugong_3")
	end,

	sfdg = function( effectScript )
			DamageEffect(P103_normal_attack.info_pool[effectScript.ID].Attacker, P103_normal_attack.info_pool[effectScript.ID].Targeter, P103_normal_attack.info_pool[effectScript.ID].AttackType, P103_normal_attack.info_pool[effectScript.ID].AttackDataList, P103_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
