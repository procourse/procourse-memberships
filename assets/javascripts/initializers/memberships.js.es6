import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeMemberships(api) {
}

export default {
  name: "apply-memberships",

  initialize() {
    withPluginApi('0.5', initializeMemberships);
  }
};