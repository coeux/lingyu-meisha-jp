S202_magic_H107_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H107_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H107_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H107_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 30, "f" )
	end,

	s = function( effectScript )
		SetAnimation(S202_magic_H107_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("manhit")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H107_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	f = function( effectScript )
			DamageEffect(S202_magic_H107_attack.info_pool[effectScript.ID].Attacker, S202_magic_H107_attack.info_pool[effectScript.ID].Targeter, S202_magic_H107_attack.info_pool[effectScript.ID].AttackType, S202_magic_H107_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H107_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
