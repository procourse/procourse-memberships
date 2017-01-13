import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeLeague(api) {

  // api.decorateCooked($elem => $("league", $elem).league());

  const ComposerController = api.container.lookupFactory("controller:composer");
  ComposerController.reopen({
    actions: {
      insertLeague() {
        console.log(this);
        this.get("toolbarEvent").applySurround(
          `[league=3]`,
          "[/league]",
          "league_text",
          { multiline: false }
        );
      }
    }
  });
}

export default {
  name: "apply-league",

  initialize() {
    withPluginApi('0.5', initializeLeague);
  }
};