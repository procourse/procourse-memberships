import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax('/league/pages');
  },

  findById(opts) {
    return ajax(`/league/p/${opts.id}`);
  }
};