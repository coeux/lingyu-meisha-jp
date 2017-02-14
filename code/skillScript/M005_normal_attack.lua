M005_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M005_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M005_normal_attack.info_pool[effectScript.ID].Attacker)
		M005_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("")
		PreLoadSound("gs0051")
		PreLoadSound("slime")
		PreLoadAvatar("guaishouji")
		PreLoadSound("slimehit")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "f" )
		effectScript:RegisterEvent( 17, "sad" )
		effectScript:RegisterEvent( 18, "s" )
		effectScript:RegisterEvent( 23, "e" )
	end,

	f = function( effectScript )
		SetAnimation(M005_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("")
		PlaySound("gs0051")
	end,

	sad = function( effectScript )
			PlaySound("slime")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, M005_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.3, 100, "guaishouji")
	end,

	e = function( effectScript )
			DamageEffect(M005_normal_attack.info_pool[effectScript.ID].Attacker, M005_normal_attack.info_pool[effectScript.ID].Targeter, M005_normal_attack.info_pool[effectScript.ID].AttackType, M005_normal_attack.info_pool[effectScript.ID].AttackDataList, M005_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
		PlaySound("slimehit")
	end,

}
