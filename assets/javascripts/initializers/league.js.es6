import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeLeague(api) {
}

export default {
  name: "apply-league",

  initialize() {
    withPluginApi('0.5', initializeLeague);
  }
};