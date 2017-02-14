H005_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H005_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H005_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H005_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H005_normal_attack.info_pool[effectScript.ID].Effect1);H005_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H005_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0501")
		PreLoadSound("skill_0502")
		PreLoadAvatar("Zshifang")
		PreLoadAvatar("szwpugong")
		PreLoadAvatar("Zshouji")
		PreLoadSound("attack_0501")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 9, "dsfh" )
		effectScript:RegisterEvent( 12, "sfsf" )
		effectScript:RegisterEvent( 19, "f" )
		effectScript:RegisterEvent( 20, "e" )
		effectScript:RegisterEvent( 21, "dd" )
		effectScript:RegisterEvent( 22, "dsfdh" )
		effectScript:RegisterEvent( 23, "a" )
	end,

	aa = function( effectScript )
		SetAnimation(H005_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_0501")
	end,

	dsfh = function( effectScript )
			PlaySound("skill_0502")
	end,

	sfsf = function( effectScript )
		AttachAvatarPosEffect(false, H005_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 100), 2.5, 100, "Zshifang")
	end,

	f = function( effectScript )
		H005_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H005_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(20, 65), 1, 500, 300, 1.5, H005_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-15, 0), "szwpugong", effectScript)
	end,

	e = function( effectScript )
		if H005_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H005_normal_attack.info_pool[effectScript.ID].Effect1);H005_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H005_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), 2.5, 100, "Zshouji")
	end,

	dsfdh = function( effectScript )
			PlaySound("attack_0501")
	end,

	a = function( effectScript )
			DamageEffect(H005_normal_attack.info_pool[effectScript.ID].Attacker, H005_normal_attack.info_pool[effectScript.ID].Targeter, H005_normal_attack.info_pool[effectScript.ID].AttackType, H005_normal_attack.info_pool[effectScript.ID].AttackDataList, H005_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
