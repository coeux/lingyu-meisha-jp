H029_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H029_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H029_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H029_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H029_normal_attack.info_pool[effectScript.ID].Effect1);H029_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H029_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("szwpugong")
		PreLoadAvatar("H029_shouji_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "v" )
		effectScript:RegisterEvent( 23, "gfdh" )
		effectScript:RegisterEvent( 24, "dfgh" )
		effectScript:RegisterEvent( 25, "gfdgf" )
	end,

	v = function( effectScript )
		SetAnimation(H029_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	gfdh = function( effectScript )
		H029_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H029_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 100), 2, 1200, 300, 1.8, H029_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "szwpugong", effectScript)
	end,

	dfgh = function( effectScript )
		if H029_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H029_normal_attack.info_pool[effectScript.ID].Effect1);H029_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	gfdgf = function( effectScript )
		AttachAvatarPosEffect(false, H029_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "H029_shouji_1")
		DamageEffect(H029_normal_attack.info_pool[effectScript.ID].Attacker, H029_normal_attack.info_pool[effectScript.ID].Targeter, H029_normal_attack.info_pool[effectScript.ID].AttackType, H029_normal_attack.info_pool[effectScript.ID].AttackDataList, H029_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
