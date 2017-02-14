H044_auto794_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H044_auto794_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H044_auto794_attack.info_pool[effectScript.ID].Attacker)
        
		H044_auto794_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H044_xuli_3")
		PreLoadAvatar("S790_2")
		PreLoadSound("attack_04404")
		PreLoadAvatar("S790_1")
		PreLoadSound("attack_04403")
		PreLoadAvatar("S790_3")
		PreLoadSound("attack_04403")
		PreLoadSound("attack_04403")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgfhj" )
		effectScript:RegisterEvent( 11, "gfhgj" )
		effectScript:RegisterEvent( 23, "sfdgfdhj" )
		effectScript:RegisterEvent( 24, "dsfdghgj" )
		effectScript:RegisterEvent( 26, "dfdgfh" )
	end,

	sfdgfhj = function( effectScript )
		SetAnimation(H044_auto794_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	AttachAvatarPosEffect(false, H044_auto794_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(15, 0), 1, -100, "H044_xuli_3")
	end,

	gfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H044_auto794_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(12, 110), 1.2, 100, "S790_2")
		PlaySound("attack_04404")
	end,

	sfdgfdhj = function( effectScript )
		AttachAvatarPosEffect(false, H044_auto794_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 130), 2, 100, "S790_1")
		PlaySound("attack_04403")
	end,

	dsfdghgj = function( effectScript )
		AttachAvatarPosEffect(false, H044_auto794_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(500, -70), 1.2, 100, "S790_3")
		PlaySound("attack_04403")
	end,

	dfdgfh = function( effectScript )
			DamageEffect(H044_auto794_attack.info_pool[effectScript.ID].Attacker, H044_auto794_attack.info_pool[effectScript.ID].Targeter, H044_auto794_attack.info_pool[effectScript.ID].AttackType, H044_auto794_attack.info_pool[effectScript.ID].AttackDataList, H044_auto794_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("attack_04403")
	end,

}
