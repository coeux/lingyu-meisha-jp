M003_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M003_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M003_normal_attack.info_pool[effectScript.ID].Attacker)
		M003_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0031")
		PreLoadSound("g0031")
		PreLoadAvatar("daoguang")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 21, "cxv" )
	end,

	sf = function( effectScript )
		SetAnimation(M003_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0031")
		PlaySound("g0031")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, M003_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 100), 3, 100, "daoguang")
	end,

	cxv = function( effectScript )
			DamageEffect(M003_normal_attack.info_pool[effectScript.ID].Attacker, M003_normal_attack.info_pool[effectScript.ID].Targeter, M003_normal_attack.info_pool[effectScript.ID].AttackType, M003_normal_attack.info_pool[effectScript.ID].AttackDataList, M003_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
