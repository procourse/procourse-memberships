import { registerUnbound } from 'discourse-common/lib/helpers';

registerUnbound('currency-symbol', function() {
  return I18n.t('memberships.currency.' + Discourse.SiteSettings.memberships_currency);
});