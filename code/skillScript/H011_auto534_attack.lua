H011_auto534_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H011_auto534_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H011_auto534_attack.info_pool[effectScript.ID].Attacker)
        
		H011_auto534_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01102")
		PreLoadAvatar("S252_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "dsfdh" )
		effectScript:RegisterEvent( 15, "ewfef" )
		effectScript:RegisterEvent( 22, "z" )
		effectScript:RegisterEvent( 24, "c" )
		effectScript:RegisterEvent( 27, "t" )
		effectScript:RegisterEvent( 29, "v" )
	end,

	a = function( effectScript )
		SetAnimation(H011_auto534_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01101")
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_01102")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto534_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2.5, 100, "S252_1")
	end,

	z = function( effectScript )
		CameraShake()
	end,

	c = function( effectScript )
			DamageEffect(H011_auto534_attack.info_pool[effectScript.ID].Attacker, H011_auto534_attack.info_pool[effectScript.ID].Targeter, H011_auto534_attack.info_pool[effectScript.ID].AttackType, H011_auto534_attack.info_pool[effectScript.ID].AttackDataList, H011_auto534_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	t = function( effectScript )
			DamageEffect(H011_auto534_attack.info_pool[effectScript.ID].Attacker, H011_auto534_attack.info_pool[effectScript.ID].Targeter, H011_auto534_attack.info_pool[effectScript.ID].AttackType, H011_auto534_attack.info_pool[effectScript.ID].AttackDataList, H011_auto534_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(H011_auto534_attack.info_pool[effectScript.ID].Attacker, H011_auto534_attack.info_pool[effectScript.ID].Targeter, H011_auto534_attack.info_pool[effectScript.ID].AttackType, H011_auto534_attack.info_pool[effectScript.ID].AttackDataList, H011_auto534_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
