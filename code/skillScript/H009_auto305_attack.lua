H009_auto305_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H009_auto305_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H009_auto305_attack.info_pool[effectScript.ID].Attacker)
        
		H009_auto305_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0901")
		PreLoadAvatar("S300_3")
		PreLoadAvatar("S300_2")
		PreLoadAvatar("S300_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 1, "asfdsgfdgh" )
		effectScript:RegisterEvent( 16, "sefh" )
		effectScript:RegisterEvent( 18, "dfhgj" )
		effectScript:RegisterEvent( 23, "sdggfh" )
		effectScript:RegisterEvent( 24, "sdfdhg" )
		effectScript:RegisterEvent( 25, "sdfdh" )
		effectScript:RegisterEvent( 27, "dfshg" )
		effectScript:RegisterEvent( 30, "fghgfdh" )
	end,

	b = function( effectScript )
		SetAnimation(H009_auto305_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0901")
	end,

	asfdsgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto305_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 10), 1.2, -100, "S300_3")
	end,

	sefh = function( effectScript )
	end,

	dfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto305_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(220, 90), 2.5, 100, "S300_2")
	end,

	sdggfh = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto305_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 2.5, 100, "S300_1")
	end,

	sdfdhg = function( effectScript )
			DamageEffect(H009_auto305_attack.info_pool[effectScript.ID].Attacker, H009_auto305_attack.info_pool[effectScript.ID].Targeter, H009_auto305_attack.info_pool[effectScript.ID].AttackType, H009_auto305_attack.info_pool[effectScript.ID].AttackDataList, H009_auto305_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sdfdh = function( effectScript )
		end,

	dfshg = function( effectScript )
			DamageEffect(H009_auto305_attack.info_pool[effectScript.ID].Attacker, H009_auto305_attack.info_pool[effectScript.ID].Targeter, H009_auto305_attack.info_pool[effectScript.ID].AttackType, H009_auto305_attack.info_pool[effectScript.ID].AttackDataList, H009_auto305_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fghgfdh = function( effectScript )
			DamageEffect(H009_auto305_attack.info_pool[effectScript.ID].Attacker, H009_auto305_attack.info_pool[effectScript.ID].Targeter, H009_auto305_attack.info_pool[effectScript.ID].AttackType, H009_auto305_attack.info_pool[effectScript.ID].AttackDataList, H009_auto305_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
