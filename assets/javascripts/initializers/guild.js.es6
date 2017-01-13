import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeGuild(api) {

  // api.decorateCooked($elem => $("guild", $elem).guild());

  const ComposerController = api.container.lookupFactory("controller:composer");
  ComposerController.reopen({
    actions: {
      insertGuild() {
        console.log(this);
        this.get("toolbarEvent").applySurround(
          `[guild=3]`,
          "[/guild]",
          "guild_text",
          { multiline: false }
        );
      }
    }
  });
}

export default {
  name: "apply-guild",

  initialize() {
    withPluginApi('0.5', initializeGuild);
  }
};