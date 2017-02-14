S310_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S310_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S310_magic_H004_attack.info_pool[effectScript.ID].Attacker)
        
		S310_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0401")
		PreLoadSound("skill_0403")
		PreLoadSound("skill_0403")
		PreLoadSound("skill_0401")
		PreLoadSound("atalk_0401")
		PreLoadSound("skill_0402")
		PreLoadAvatar("S310")
		PreLoadSound("skill_0402")
		PreLoadSound("skill_0402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "z" )
		effectScript:RegisterEvent( 3, "jhgkjhkl" )
		effectScript:RegisterEvent( 18, "sfsdh" )
		effectScript:RegisterEvent( 45, "a" )
		effectScript:RegisterEvent( 60, "dgfh" )
		effectScript:RegisterEvent( 65, "gfdhj" )
		effectScript:RegisterEvent( 68, "aafdf" )
		effectScript:RegisterEvent( 70, "sdfdh" )
		effectScript:RegisterEvent( 72, "x" )
		effectScript:RegisterEvent( 73, "dfghfj" )
		effectScript:RegisterEvent( 75, "c" )
	end,

	z = function( effectScript )
		SetAnimation(S310_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_0401")
	end,

	jhgkjhkl = function( effectScript )
			PlaySound("skill_0403")
	end,

	sfsdh = function( effectScript )
			PlaySound("skill_0403")
	end,

	a = function( effectScript )
		SetAnimation(S310_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dgfh = function( effectScript )
			PlaySound("skill_0401")
		PlaySound("atalk_0401")
	end,

	gfdhj = function( effectScript )
			PlaySound("skill_0402")
	end,

	aafdf = function( effectScript )
		AttachAvatarPosEffect(false, S310_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 250), 1.5, 100, "S310")
	end,

	sdfdh = function( effectScript )
			PlaySound("skill_0402")
	end,

	x = function( effectScript )
			DamageEffect(S310_magic_H004_attack.info_pool[effectScript.ID].Attacker, S310_magic_H004_attack.info_pool[effectScript.ID].Targeter, S310_magic_H004_attack.info_pool[effectScript.ID].AttackType, S310_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S310_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfghfj = function( effectScript )
			PlaySound("skill_0402")
	end,

	c = function( effectScript )
			DamageEffect(S310_magic_H004_attack.info_pool[effectScript.ID].Attacker, S310_magic_H004_attack.info_pool[effectScript.ID].Targeter, S310_magic_H004_attack.info_pool[effectScript.ID].AttackType, S310_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S310_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
