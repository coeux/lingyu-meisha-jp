H042_auto777_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H042_auto777_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H042_auto777_attack.info_pool[effectScript.ID].Attacker)
        
		H042_auto777_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_04201")
		PreLoadAvatar("S772_1")
		PreLoadAvatar("S772_2")
		PreLoadAvatar("S772_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hhgjkkkkkjhjhku" )
		effectScript:RegisterEvent( 5, "jhgjkhlk" )
		effectScript:RegisterEvent( 20, "fdgfhj" )
		effectScript:RegisterEvent( 24, "fdghjjj" )
		effectScript:RegisterEvent( 27, "hjgjkk" )
	end,

	hhgjkkkkkjhjhku = function( effectScript )
		SetAnimation(H042_auto777_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_04201")
	end,

	jhgjkhlk = function( effectScript )
		AttachAvatarPosEffect(false, H042_auto777_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(5, 70), 1.5, 100, "S772_1")
	end,

	fdgfhj = function( effectScript )
		AttachAvatarPosEffect(false, H042_auto777_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 50), 1.5, 100, "S772_2")
	end,

	fdghjjj = function( effectScript )
		AttachAvatarPosEffect(false, H042_auto777_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S772_3")
	end,

	hjgjkk = function( effectScript )
			DamageEffect(H042_auto777_attack.info_pool[effectScript.ID].Attacker, H042_auto777_attack.info_pool[effectScript.ID].Targeter, H042_auto777_attack.info_pool[effectScript.ID].AttackType, H042_auto777_attack.info_pool[effectScript.ID].AttackDataList, H042_auto777_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
