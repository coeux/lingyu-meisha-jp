S121_magic_M049_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S121_magic_M049_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S121_magic_M049_attack.info_pool[effectScript.ID].Attacker)
		S121_magic_M049_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("shenshengchongji")
		PreLoadAvatar("S121")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 40, "df" )
		effectScript:RegisterEvent( 41, "d" )
		effectScript:RegisterEvent( 43, "f" )
		effectScript:RegisterEvent( 44, "g" )
	end,

	a = function( effectScript )
		SetAnimation(S121_magic_M049_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("shenshengchongji")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S121_magic_M049_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, -20), 1, 100, "S121")
	CameraShake()
	CameraShake()
	end,

	f = function( effectScript )
		end,

	g = function( effectScript )
			DamageEffect(S121_magic_M049_attack.info_pool[effectScript.ID].Attacker, S121_magic_M049_attack.info_pool[effectScript.ID].Targeter, S121_magic_M049_attack.info_pool[effectScript.ID].AttackType, S121_magic_M049_attack.info_pool[effectScript.ID].AttackDataList, S121_magic_M049_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
