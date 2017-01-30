import { licensed } from 'discourse/plugins/discourse-league/discourse/lib/constraint';
import LeagueGateway from '../models/league-gateway';

export default Ember.Controller.extend({

  licensed: licensed(),

  gateways: LeagueGateway.findAll(),

  actions: {

    save: function() {
      if (this.get('selectedItem').slug == this.slugify(this.get('selectedItem').title)){
        this.get('selectedItem').set('custom_slug', false);
      }
      LeaguePage.save(this.get('selectedItem'));
      this.send('selectDLPage', this.get('selectedItem'));
    }
  }
});