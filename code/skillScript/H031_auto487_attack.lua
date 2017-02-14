H031_auto487_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H031_auto487_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H031_auto487_attack.info_pool[effectScript.ID].Attacker)
        
		H031_auto487_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0312")
		PreLoadSound("s0313")
		PreLoadAvatar("H031_pugong_1")
		PreLoadAvatar("S472_1")
		PreLoadAvatar("S340_fazhen")
		PreLoadAvatar("S480_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdshg" )
		effectScript:RegisterEvent( 4, "safsdg" )
		effectScript:RegisterEvent( 13, "fdhgj" )
		effectScript:RegisterEvent( 17, "gfdhf" )
		effectScript:RegisterEvent( 18, "gvfdh" )
		effectScript:RegisterEvent( 22, "sfg" )
	end,

	dsfdshg = function( effectScript )
		SetAnimation(H031_auto487_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0312")
		PlaySound("s0313")
	end,

	safsdg = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto487_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-55, 60), 1.2, 100, "H031_pugong_1")
	end,

	fdhgj = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto487_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 50), 1, 100, "S472_1")
	end,

	gfdhf = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto487_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.8, -100, "S340_fazhen")
	end,

	gvfdh = function( effectScript )
		AttachAvatarPosEffect(false, H031_auto487_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S480_2")
	end,

	sfg = function( effectScript )
			DamageEffect(H031_auto487_attack.info_pool[effectScript.ID].Attacker, H031_auto487_attack.info_pool[effectScript.ID].Targeter, H031_auto487_attack.info_pool[effectScript.ID].AttackType, H031_auto487_attack.info_pool[effectScript.ID].AttackDataList, H031_auto487_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
