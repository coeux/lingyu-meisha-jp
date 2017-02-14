S482_magic_H031_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S482_magic_H031_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S482_magic_H031_attack.info_pool[effectScript.ID].Attacker)
        
		S482_magic_H031_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0315")
		PreLoadSound("s0312")
		PreLoadAvatar("H031_pugong_1")
		PreLoadAvatar("S472_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgfd" )
		effectScript:RegisterEvent( 45, "dsfdshg" )
		effectScript:RegisterEvent( 49, "safsdg" )
		effectScript:RegisterEvent( 58, "fdhgj" )
		effectScript:RegisterEvent( 63, "sfg" )
	end,

	dsgfd = function( effectScript )
		SetAnimation(S482_magic_H031_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0315")
	end,

	dsfdshg = function( effectScript )
		SetAnimation(S482_magic_H031_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0312")
	end,

	safsdg = function( effectScript )
		AttachAvatarPosEffect(false, S482_magic_H031_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-55, 60), 1.2, 100, "H031_pugong_1")
	end,

	fdhgj = function( effectScript )
		AttachAvatarPosEffect(false, S482_magic_H031_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 50), 1, 100, "S472_1")
	end,

	sfg = function( effectScript )
			DamageEffect(S482_magic_H031_attack.info_pool[effectScript.ID].Attacker, S482_magic_H031_attack.info_pool[effectScript.ID].Targeter, S482_magic_H031_attack.info_pool[effectScript.ID].AttackType, S482_magic_H031_attack.info_pool[effectScript.ID].AttackDataList, S482_magic_H031_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
