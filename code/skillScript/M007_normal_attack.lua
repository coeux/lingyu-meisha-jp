M007_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M007_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M007_normal_attack.info_pool[effectScript.ID].Attacker)
		M007_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0071")
		PreLoadSound("g0071")
		PreLoadAvatar("lang")
		PreLoadAvatar("guaishouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 21, "r" )
		effectScript:RegisterEvent( 22, "g" )
		effectScript:RegisterEvent( 23, "e" )
	end,

	aa = function( effectScript )
		SetAnimation(M007_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0071")
		PlaySound("g0071")
	end,

	s = function( effectScript )
		M007_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M007_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(-30, 10), 1, 500, 400, 0.7, M007_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "lang", effectScript)
	end,

	r = function( effectScript )
			DamageEffect(M007_normal_attack.info_pool[effectScript.ID].Attacker, M007_normal_attack.info_pool[effectScript.ID].Targeter, M007_normal_attack.info_pool[effectScript.ID].AttackType, M007_normal_attack.info_pool[effectScript.ID].AttackDataList, M007_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	g = function( effectScript )
		AttachAvatarPosEffect(false, M007_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 1, 100, "guaishouji")
	end,

	e = function( effectScript )
		DetachEffect(M007_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

}
