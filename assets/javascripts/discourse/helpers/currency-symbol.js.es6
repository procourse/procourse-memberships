import { registerUnbound } from 'discourse-common/lib/helpers';

registerUnbound('currency-symbol', function() {
  return I18n.t('league.currency.' + Discourse.SiteSettings.league_currency);
});