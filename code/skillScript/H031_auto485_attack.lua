H031_auto485_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H031_auto485_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H031_auto485_attack.info_pool[effectScript.ID].Attacker)
        
		H031_auto485_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0312")
		PreLoadSound("s0317")
		PreLoadAvatar("H031_pugong_1")
		PreLoadAvatar("S472_1")
		PreLoadAvatar("S212_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdshg" )
		effectScript:RegisterEvent( 4, "safsdg" )
		effectScript:RegisterEvent( 13, "fdhgj" )
		effectScript:RegisterEvent( 17, "gfdhf" )
		effectScript:RegisterEvent( 19, "sfg" )
	end,

	dsfdshg = function( effectScript )
		SetAnimation(H031_auto485_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0312")
		PlaySound("s0317")
	end,

	safsdg = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto485_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-55, 60), 1.2, 100, "H031_pugong_1")
	end,

	fdhgj = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto485_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 50), 1, 100, "S472_1")
	end,

	gfdhf = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto485_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S212_2")
	end,

	sfg = function( effectScript )
			DamageEffect(H031_auto485_attack.info_pool[effectScript.ID].Attacker, H031_auto485_attack.info_pool[effectScript.ID].Targeter, H031_auto485_attack.info_pool[effectScript.ID].AttackType, H031_auto485_attack.info_pool[effectScript.ID].AttackDataList, H031_auto485_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
