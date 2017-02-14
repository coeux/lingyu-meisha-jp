S222_magic_M082_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_M082_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_M082_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_M082_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("fire")
		PreLoadAvatar("S222")
		PreLoadSound("odin")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "df" )
		effectScript:RegisterEvent( 25, "f" )
		effectScript:RegisterEvent( 29, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S222_magic_M082_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("fire")
	end,

	f = function( effectScript )
			DamageEffect(S222_magic_M082_attack.info_pool[effectScript.ID].Attacker, S222_magic_M082_attack.info_pool[effectScript.ID].Targeter, S222_magic_M082_attack.info_pool[effectScript.ID].AttackType, S222_magic_M082_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_M082_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S222_magic_M082_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S222")
		PlaySound("odin")
	end,

}
