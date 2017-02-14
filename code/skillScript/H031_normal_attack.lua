H031_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H031_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H031_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H031_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0311")
		PreLoadAvatar("H031_pugong_1")
		PreLoadAvatar("H031_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "kjl" )
		effectScript:RegisterEvent( 12, "kiul" )
		effectScript:RegisterEvent( 19, "dsg" )
		effectScript:RegisterEvent( 21, "sed" )
	end,

	kjl = function( effectScript )
		SetAnimation(H031_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s0311")
	end,

	kiul = function( effectScript )
		AttachAvatarPosEffect(false, H031_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 50), 1, 100, "H031_pugong_1")
	end,

	dsg = function( effectScript )
		AttachAvatarPosEffect(false, H031_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), 1.2, 100, "H031_pugong_2")
	end,

	sed = function( effectScript )
			DamageEffect(H031_normal_attack.info_pool[effectScript.ID].Attacker, H031_normal_attack.info_pool[effectScript.ID].Targeter, H031_normal_attack.info_pool[effectScript.ID].AttackType, H031_normal_attack.info_pool[effectScript.ID].AttackDataList, H031_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
