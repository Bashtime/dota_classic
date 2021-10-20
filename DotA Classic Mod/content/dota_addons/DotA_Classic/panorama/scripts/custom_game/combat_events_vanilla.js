var CombatEvents = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("ToastManager");

// SetHeroKillGold({gold_bounty: 200});

function SetHeroKillGold(data) {
	$.Msg(data);
	var event_panel = CombatEvents.GetChild(0);

	if (event_panel && event_panel.BHasClass("event_dota_player_kill") && (!event_panel.gold_rune_set || Game.IsInToolsMode())) {
		// tools mode needs 
		if (Game.IsInToolsMode()) {
			if (event_panel.FindChildTraverse("additional_text")) {
				event_panel.FindChildTraverse("additional_text").DeleteAsync(0);
			}

			if (event_panel.FindChildTraverse("additional_tex2")) {
				event_panel.FindChildTraverse("additional_tex2").DeleteAsync(0);
			}

			if (event_panel.FindChildTraverse("gold_image")) {
				event_panel.FindChildTraverse("gold_image").DeleteAsync(0);
			}

			if (event_panel.FindChildTraverse("additional_container")) {
				event_panel.FindChildTraverse("additional_container").DeleteAsync(0);
			}
		}

		let gold_text = "";
		let label = event_panel.FindChildTraverse("EventLabel");
		let register_gold = [];

		for (let index = 3; index < 8; index++) {
			var letter = label.text[label.text.length - index];

			if (letter != "") {
				if (parseInt(letter) || parseInt(letter) == 0) {
					register_gold.push(letter);
				}
			}
		}

		for (let index = 0; index < register_gold.length; index++) {
			const element = register_gold[register_gold.length - index - 1];
			gold_text = gold_text + element;
		}

		$.Msg(gold_text);
		$.Msg(label.text);

		label.text = label.text.replace(gold_text, data.gold_bounty);

		event_panel.gold_rune_set = true;
	}
};

(function() {
	GameEvents.Subscribe('set_hero_kill_gold', SetHeroKillGold);
})();
