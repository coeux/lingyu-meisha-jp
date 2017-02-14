H017_auto619_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H017_auto619_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H017_auto619_attack.info_pool[effectScript.ID].Attacker)
       	if H017_auto619_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H017_auto619_attack.info_pool[effectScript.ID].Effect1);H017_auto619_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H017_auto619_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01701")
		PreLoadSound("stalk_01701")
		PreLoadAvatar("S212_3")
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "dsfdsf" )
		effectScript:RegisterEvent( 18, "adsad" )
		effectScript:RegisterEvent( 19, "dsfd" )
		effectScript:RegisterEvent( 20, "sfdf" )
		effectScript:RegisterEvent( 21, "s" )
	end,

	a = function( effectScript )
		SetAnimation(H017_auto619_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_01701")
		PlaySound("stalk_01701")
	end,

	dsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, H017_auto619_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 80), 1.5, 100, "S212_3")
	end,

	adsad = function( effectScript )
		H017_auto619_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H017_auto619_attack.info_pool[effectScript.ID].Attacker, Vector2(130, -30), 3, 1000, 300, 1.5, H017_auto619_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S212_1", effectScript)
	end,

	dsfd = function( effectScript )
		if H017_auto619_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H017_auto619_attack.info_pool[effectScript.ID].Effect1);H017_auto619_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, H017_auto619_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S212_2")
	end,

	s = function( effectScript )
			DamageEffect(H017_auto619_attack.info_pool[effectScript.ID].Attacker, H017_auto619_attack.info_pool[effectScript.ID].Targeter, H017_auto619_attack.info_pool[effectScript.ID].AttackType, H017_auto619_attack.info_pool[effectScript.ID].AttackDataList, H017_auto619_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
