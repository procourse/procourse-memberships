import { ajax } from 'discourse/lib/ajax';

export default {
  getDashboard() {
    return ajax('https://discourseleague.com/dashboard-topic').catch(function(){
      return {"cooked": I18n.t('memberships.dashboard_default')};
    });
  }
};