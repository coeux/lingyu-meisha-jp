H041_auto764_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H041_auto764_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H041_auto764_attack.info_pool[effectScript.ID].Attacker)
        
		H041_auto764_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S760_3")
		PreLoadSound("skill_04102")
		PreLoadAvatar("S760_2")
		PreLoadAvatar("S760_1")
		PreLoadSound("skill_04101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdgfj" )
		effectScript:RegisterEvent( 1, "sdfdgj" )
		effectScript:RegisterEvent( 10, "dsgdfhhjh" )
		effectScript:RegisterEvent( 14, "sdfsdgh" )
		effectScript:RegisterEvent( 17, "dsfdhghj" )
	end,

	dgfdgfj = function( effectScript )
		SetAnimation(H041_auto764_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sdfdgj = function( effectScript )
		AttachAvatarPosEffect(false, H041_auto764_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 130), 1.2, 100, "S760_3")
		PlaySound("skill_04102")
	end,

	dsgdfhhjh = function( effectScript )
		AttachAvatarPosEffect(false, H041_auto764_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 30), 1.5, 100, "S760_2")
	end,

	sdfsdgh = function( effectScript )
		AttachAvatarPosEffect(false, H041_auto764_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S760_1")
		PlaySound("skill_04101")
	end,

	dsfdhghj = function( effectScript )
			DamageEffect(H041_auto764_attack.info_pool[effectScript.ID].Attacker, H041_auto764_attack.info_pool[effectScript.ID].Targeter, H041_auto764_attack.info_pool[effectScript.ID].AttackType, H041_auto764_attack.info_pool[effectScript.ID].AttackDataList, H041_auto764_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
