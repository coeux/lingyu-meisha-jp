H017_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H017_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H017_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H017_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H017_normal_attack.info_pool[effectScript.ID].Effect1);H017_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H017_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01701")
		PreLoadSound("attack_01701")
		PreLoadAvatar("bmshifa")
		PreLoadAvatar("bmpugong")
		PreLoadSound("attack_01702")
		PreLoadAvatar("bmshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asfasf" )
		effectScript:RegisterEvent( 8, "fdhj" )
		effectScript:RegisterEvent( 16, "asdsad" )
		effectScript:RegisterEvent( 24, "dd" )
		effectScript:RegisterEvent( 25, "cc" )
		effectScript:RegisterEvent( 26, "dgfhj" )
		effectScript:RegisterEvent( 27, "a" )
		effectScript:RegisterEvent( 28, "aaaas" )
	end,

	asfasf = function( effectScript )
		SetAnimation(H017_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_01701")
	end,

	fdhj = function( effectScript )
			PlaySound("attack_01701")
	end,

	asdsad = function( effectScript )
		AttachAvatarPosEffect(false, H017_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 110), 1.25, 100, "bmshifa")
	end,

	dd = function( effectScript )
		H017_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H017_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(20, 100), 2, 1500, 0, 1.5, H017_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-50, 0), "bmpugong", effectScript)
	end,

	cc = function( effectScript )
		if H017_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H017_normal_attack.info_pool[effectScript.ID].Effect1);H017_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dgfhj = function( effectScript )
			PlaySound("attack_01702")
	end,

	a = function( effectScript )
		AttachAvatarPosEffect(false, H017_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "bmshouji")
	end,

	aaaas = function( effectScript )
			DamageEffect(H017_normal_attack.info_pool[effectScript.ID].Attacker, H017_normal_attack.info_pool[effectScript.ID].Targeter, H017_normal_attack.info_pool[effectScript.ID].AttackType, H017_normal_attack.info_pool[effectScript.ID].AttackDataList, H017_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
